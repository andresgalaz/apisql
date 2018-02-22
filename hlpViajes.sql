SELECT e1.nIdViaje, e1.tEvento, e1.fVehiculo, v.cPatente, v.fUsuarioTitular, u.cNombre, u.cEmail
     , round( timestampdiff( minute, e1.tEvento, e2.tEvento)/60.0, 2) duracion_horas
     , round( e2.nValor, 2) kms
     , round( e2.nValor / (timestampdiff( minute, e1.tEvento, e2.tEvento)/60.0),2) kms_hr 
FROM score.tEvento e1 inner join score.tEvento e2 on e2.nIdViaje = e1.nIdViaje and e2.fTpEvento = 2 
     inner join tVehiculo v on v.pVehiculo = e1.fVehiculo
     inner join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where e1.fTpEvento = 1 
-- KMS /hr
and round( e2.nValor / (timestampdiff( minute, e1.tEvento, e2.tEvento)/60.0),2) between 0 and 5
-- Duración
and round( timestampdiff( minute, e1.tEvento, e2.tEvento)/60.0, 2) > 1 
--
and e1.tEvento >= '2017-11-01'
order by 3 desc;


SELECT e1.nIdViaje, e1.tEvento, e1.fVehiculo, v.cPatente, v.fUsuarioTitular, u.cNombre, u.cEmail
     , round( timestampdiff( minute, e1.tEvento, e2.tEvento)/60.0, 2) duracion_horas
     , round( e2.nValor, 2) kms
     , round( e2.nValor / (timestampdiff( minute, e1.tEvento, e2.tEvento)/60.0),2) kms_hr 
FROM score.tEvento e1 inner join score.tEvento e2 on e2.nIdViaje = e1.nIdViaje and e2.fTpEvento = 2 
     inner join tVehiculo v on v.pVehiculo = e1.fVehiculo
     inner join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where e1.fTpEvento = 1 
and   e1.nIdViaje = 99616
order by 3 desc;

SELECT e1.nIdViaje, e1.tEvento, e1.fVehiculo, v.cPatente, v.fUsuarioTitular, u.cNombre, u.cEmail
FROM score.tEvento e1 
     inner join tVehiculo v on v.pVehiculo = e1.fVehiculo
     inner join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where e1.fTpEvento not in ( 1, 2 )
and   e1.nIdViaje = 99616
order by 3 desc;



SELECT t.id trip_id, c.vehicle_id, c.driver_id, 
        DATE_SUB(t.from_date,interval 3 HOUR) from_date, 
        DATE_SUB(t.to_date  ,interval 3 HOUR) to_date, 
		 timestampdiff(SECOND,t.from_date, t.to_date) duracion_seg, 
        ROUND(t.distance/1000,2) distance, 
        SUM( CASE WHEN o.prefix_observation = 'A' THEN 1 ELSE 0 END ) as aceleracion, 
        SUM( CASE WHEN o.prefix_observation = 'C' THEN 1 ELSE 0 END ) as curva, 
        SUM( CASE WHEN o.prefix_observation = 'E' THEN 1 ELSE 0 END ) as velocidad, 
        SUM( CASE WHEN o.prefix_observation = 'F' THEN 1 ELSE 0 END ) as frenada 
 FROM   snapcar.trips t 
        INNER JOIN      snapcar.clients c on c.id = t.client_id 
        LEFT OUTER JOIN snapcar.trip_observations_no_deleted_view o ON o.trip_id = t.id 
 WHERE  round(t.distance/1000,2) > 0.0 
 and ( t.from_date BETWEEN '2018-14-01 00:00:00' and '2018-14-01 23:59:59' OR
       t.to_date BETWEEN '2018-14-01 00:00:00' and '2018-14-01 23:59:59' )
 AND    c.vehicle_id = 394
 AND    c.driver_id  = 183 
 -- AND    t.`status` = 'S'
 -- AND    t.from_date >= date_add( date('2017-08-07'), interval 3 hour) 
 -- AND    t.from_date <  date_add(date_add( date('2017-11-07'), interval 3 hour), interval 1 day) 
 GROUP  BY t.id, c.vehicle_id, c.driver_id, t.from_date, t.to_date, t.distance 
 ORDER  BY from_date DESC;

SELECT det.id, det.latitude lat, det.longitude lng, 
       date_sub(det.event_date,interval 3 hour)  fecha, 
       obs.id id_obs, 
       obs.prefix_observation prefijo, obs.observed_value valor, 
       obs.permited_value permitido, 
       snapcar.fnNombreCalle( 'C', str.name, str.street_number, str.town, str.city, str.substate, str.state, str.country ) calle_corta, 
       snapcar.fnNombreCalle( 'L', str.name, str.street_number, str.town, str.city, str.substate, str.state, str.country ) calle_larga, 
       str.name street_name, str.town, str.city 
 FROM  snapcar.trip_details det 
       LEFT OUTER JOIN snapcar.trip_observations_no_deleted_view obs 
            ON  obs.trip_id   = det.trip_id 
            AND obs.from_time = det.event_date 
       LEFT OUTER JOIN snapcar.g_streets str ON str.id = obs.street_id 
 WHERE det.trip_id = 40010
 AND   det.speed_ms > 0 
 ORDER BY fecha ASC;
 
 SELECT det.latitude, det.longitude, count(*)
 FROM  snapcar.trip_details det 
 WHERE det.trip_id = 40010
 group by det.latitude, det.longitude;
 
 SELECT * from snapcar.trips where id = 40010;
 DELETE from score.tEvento  where nIdViaje = 40010;