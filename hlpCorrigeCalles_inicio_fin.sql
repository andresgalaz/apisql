-- DETECCIÓN
DROP table IF EXISTS AGV;
create table AGV as 
select e.nIdViaje, e.pEvento, 'INICIO' tp,e.cCalle, t.start_street_id, snapcar.fnNombreCalle( 'L', s.name, s.street_number, s.town, s.city, s.substate, s.state, s.country ) calle
     , snapcar.fnNombreCalle( 'C', s.name, s.street_number, s.town, s.city, s.substate, s.state, s.country ) calle_corta
from tEvento e 
	left join snapcar.trips t on t.id = e.nIdViaje
    left join snapcar.g_streets s on s.id = t.start_street_id
where fTpEvento in (1)
union all
select e.nIdViaje, e.pEvento, 'FIN' tp, e.cCalle, t.end_street_id, snapcar.fnNombreCalle( 'L', s.name, s.street_number, s.town, s.city, s.substate, s.state, s.country ) calle
      , snapcar.fnNombreCalle( 'C', s.name, s.street_number, s.town, s.city, s.substate, s.state, s.country ) calle_corta
from tEvento e 
	left join snapcar.trips t on t.id = e.nIdViaje
    left join snapcar.g_streets s on s.id = t.end_street_id
where fTpEvento in (2);
create index I_AGV on AGV ( pEvento );

-- select * from AGV where calle is  null and cCalle is not null
-- union all
select * from AGV where calle is not null and cCalle is null
union all
select * from AGV where calle is not null and cCalle <>calle;

-- CORRECCION
-- Actualiza las que quedaron nulas
update tEvento set cCalle=(select calle from AGV where AGV.pEvento = tEvento.pEvento ),  cCalleCorta=(select calle_corta from AGV where AGV.pEvento = tEvento.pEvento )
WHERE pEvento in ( select AGV.pEvento from AGV where calle is not null and cCalle is null);

-- Actualiza las diferencias
update tEvento set cCalle=(select calle from AGV where AGV.pEvento = tEvento.pEvento ),  cCalleCorta=(select calle_corta from AGV where AGV.pEvento = tEvento.pEvento )
WHERE pEvento in ( select AGV.pEvento from AGV where calle is not null and cCalle <>calle);

DROP table IF EXISTS AGV;
