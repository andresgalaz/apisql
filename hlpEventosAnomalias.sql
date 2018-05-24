drop table if exists score.wEventoAnomalia;
create table score.wEventoAnomalia as
select trip_id, prefix_observation, count(*) cantidad
from snapcar.trip_observations_g
where from_time >= '2018-03-01'
and status='OK'
group by trip_id, prefix_observation
order by cantidad desc;

-- Por tiempo
select t.client_id, c.vehicle_id, t.id trip_id,t.from_date, t.to_date, v.cPatente, v.cIdDispositivo, u.cNombre, u.cEmail, a.prefix_observation, a.cantidad
     , time_to_sec( timediff(t.to_date, t.from_date ))/60 minutos, a.cantidad / time_to_sec( timediff(t.to_date, t.from_date )) cantXseg
from score.wEventoAnomalia a
	inner join snapcar.trips	t on t.id = a.trip_id
	inner join snapcar.clients	c on c.id = t.client_id
	inner join score.tVehiculo	v on v.pVehiculo = c.vehicle_id
	inner join score.tUsuario	u on u.pUsuario = v.fUsuarioTitular   
    
 where v.cPatente  in ('AB508RX')
-- and v.cPatente = 'LQB799'
order by from_date desc
limit 10000
;    

-- Acumulado x KM
select t.client_id, c.vehicle_id, substr(t.from_date,1,7) periodo, v.cPatente, v.cIdDispositivo, u.cNombre, u.cEmail, a.prefix_observation, sum(a.cantidad) cantidad, round(sum(t.distance)/1000) distance
     , 1000 * sum(a.cantidad) / sum(t.distance) cantXkm
--     , time_to_sec( timediff(t.to_date, t.from_date ))/60 minutos, a.cantidad / time_to_sec( timediff(t.to_date, t.from_date )) cantXseg
from score.wEventoAnomalia a
	inner join snapcar.trips	t on t.id = a.trip_id
	inner join snapcar.clients	c on c.id = t.client_id
	inner join score.tVehiculo	v on v.pVehiculo = c.vehicle_id
	inner join score.tUsuario	u on u.pUsuario = v.fUsuarioTitular   
    
where v.cPatente in ('JBH851'    )
group by t.client_id, c.vehicle_id, substr(t.from_date,1,7), v.cPatente, v.cIdDispositivo, u.cNombre, u.cEmail, a.prefix_observation
order by cantidad desc
;    

select * from snapcar.clients where vehicle_id=492
;

-- Genera proceso a recalcular
select concat('call prRecalculaScore(','\'',  fnFechaCierreIni(dIniVigencia, -1) - interval 1 day, '\'',',',pVehiculo,',',fUsuarioTitular,'); -- ', cPatente) 
from tVehiculo 
where cPatente in ('AA021MA') and bVigente='1' -- pVehiculo=544 -- OR cPatente in ('KZI628') and bVigente='1'; -- pVehiculo in (494)
;
call prRecalculaScore('2018-02-03',437,267); -- JBH851
;

-- Marca eventos en la BD de LUXO
update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation = 'A'
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 565  ) 
;
delete from score.tEvento WHERE fTpEvento = 3
AND fVehiculo = 534
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F' )
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 531  ) -- JBH851
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4 )
AND fVehiculo = 437 -- JBH851
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F' )
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 547  ) -- FAA680
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4 )
AND fVehiculo = 505 -- FAA680
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F' )
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 541  ) -- EXM369
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4 )
AND fVehiculo = 426 -- EXM369
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F' )
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 524  ) -- KPI916
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4 )
AND fVehiculo = 423 -- KPI916
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F' )
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 524  ) -- KPI916
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4 )
AND fVehiculo = 423 -- KPI916
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F' )
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 538  ) -- MRW848
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4 )
AND fVehiculo = 483 -- MRW848
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F', 'C' )
AND status <> 'D'
AND trip_id in ( SELECT id FROM snapcar.trips WHERE client_id = 521  ) -- NXL561
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4, 6 )
AND fVehiculo = 414 -- NXL561
;

update snapcar.trip_observations_g set status = 'D'
WHERE prefix_observation in ( 'A', 'F', 'C' )
AND status <> 'D'
AND trip_id = 125726 -- LQB799
;
delete from score.tEvento WHERE fTpEvento in ( 3, 4, 6 )
AND nIdViaje = 125726 -- LQB799
;



-- Informe para JAM de algunos casos
# trip_id, from_date, to_date, cPatente, cIdDispositivo, cNombre, cEmail, prefix_observation, cantidad
# '126859', '2018-02-10 11:01:34', '2018-02-10 12:55:55', 'JBH851', '0087', 'Ricardo Alberto Sobrero', 'rsobrero@temaiken.org.ar', 'A', '382'
# '121954', '2018-02-14 13:31:00', '2018-02-14 17:38:55', 'AA429CP', '0147', 'MIRIAN SOLEDAD OJEDA SANCHEZ', 'ojeda_mirian.s@hotmail.com', 'A', '285'
# '138749', '2018-02-25 18:29:00', '2018-02-25 18:56:55', 'FAA680', '0227', 'GONZALO PUEBLA', 'gonzalopuebla@icloud.com', 'A', '110'

SELECT * FROM snapcar.trip_details 
where trip_id=126859
-- and event_date between 
-- '2018-02-10 11:01:34' '2018-02-10 12:55:55'
;
SELECT * FROM snapcar.trip_observations_g  o
where o.trip_id = 138749
;

SELECT o.id id_evento, o.prefix_observation, o.from_time, o.to_time
	 , CASE WHEN d.event_date BETWEEN o.from_time AND o.to_time THEN 'DENTRO' ELSE 'FUERA' END 'intervalo_ocurrencia'
     , d.event_date, d.latitude, d.longitude, d.altitude, d.speed_ms, d.virloc_event, d.position_type, d.position_age, d.x, d.y, d.z, d.ignition
     -- o.*, d.*
FROM snapcar.trip_observations_g  o
	INNER JOIN snapcar.trip_details d ON d.trip_id = o.trip_id
									AND d.event_date between from_time - interval 20 SECOND and to_time + interval 20 SECOND
where o.trip_id = 138749 limit 40000
;


