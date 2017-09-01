SELECT * FROM score.wEventoHist where nIdViaje in (14435, 14502) order by pEvento;
SELECT * FROM score.wEventoHist where tProceso = '2017-08-30 17:15:09' and fTpEvento in (1,2,3,4,5) order by pEvento;
select trip_id, fecha_ini + interval -3 hour fecha_ini, fecha_fin + interval -3 HOUR fecha_fin, obs_fecha + interval -3 hour
	 , vehicle_id, driver_id, prefix, calle, calle_fin, ts_modif
 from snapcar.trip_observations_view where trip_id in (14435, 14502) order by obs_fecha;

SELECT w.tProceso, w.fVehiculo, w.fUsuario, w.fTpEvento, w.tEvento, w.cCalle, v.vehicle_id, v.driver_id, v.prefix, v.calle_inicio, v.calle_fin from score.wEventoHist w left join snapcar.trip_observations_view v on v.observation_id = w.nIdObservation
where w.nIdViaje=14435 and w.fTpEvento in (1,2);

SELECT w.tProceso, w.fVehiculo, w.fUsuario, w.fTpEvento, w.tEvento, w.cCalle, v.vehicle_id, v.driver_id, v.prefix, v.calle_inicio, v.calle_fin  FROM snapcar.trip_observations_view v left join score.wEventoHist w on w.nIdObservation = v.observation_id
where v.trip_id=14435 and w.fTpEvento in (1,2);

SELECT * FROM score.wEventoHist where cCalle like '%1369%';