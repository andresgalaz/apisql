DROP VIEW IF EXISTS vEvento;
CREATE	VIEW vEvento AS
select	ev.fVehiculo, ev.nIdViaje, v.fUsuarioTitular, ev.fUsuario, ev.fTpEvento, tp.cDescripcion as cEvento
	,	ev.tEvento, ev.nLG, ev.nLT, ev.nValor, ev.nVelocidadMaxima, ev.cCalle as cCalle, ev.nPuntaje
from	tEvento ev
		-- Es un solo registro
		inner join tParamCalculo param 
		-- Solo considera viajes con KM mayor a 300 metros
		inner join tEvento		ef	on	ef.nIdViaje		= ev.nIdViaje
									and	ef.fTpEvento	= 2
									and ef.nValor		> param.nDistanciaMin
		inner join tTpEvento	tp	on	tp.pTpEvento	= ev.fTpEvento
		inner join tVehiculo	v	on	v.pVehiculo		= ev.fVehiculo
where	-- ev.fTpEvento in ('3','4','5') and
		not exists	(	select	'x' 
						from	wEventoDeleted we
						where	we.trip_id				= ev.nIdViaje 
						and		we.prefix_observation	= tp.cPrefijo
						and		we.from_time			= date_add(ev.tEvento,interval 3 hour)
					)
