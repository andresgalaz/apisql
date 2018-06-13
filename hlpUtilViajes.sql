-- Detecta no actualización entre Viajes y Facturas
create table agv as
SELECT t.id viaje, t.updated_at, MAX(o.updated_at) max
 FROM   snapcar.trips t 
        JOIN snapcar.trip_observations_g o ON o.trip_id = t.id
                                          AND o.`status` = 'OK'
WHERE 1=1 -- MAX(o.update_at) > t.updated_at     
AND t.from_date >= '2018-01-01'

GROUP BY t.id, t.updated_at
HAVING MAX(o.updated_at) > t.updated_at     ;

SELECT t.id trip_id, t.client_id, c.vehicle_id, c.driver_id, 
        DATE_SUB(t.from_date,interval 3 HOUR) from_date, 
        DATE_SUB(t.to_date  ,interval 3 HOUR) to_date, 
        t.updated_at,
		 timestampdiff(SECOND,t.from_date, t.to_date) duracion_seg, 
        ROUND(t.distance/1000,2) distance, 
        SUM( CASE WHEN o.prefix_observation = 'A' THEN 1 ELSE 0 END ) as aceleracion, 
        SUM( CASE WHEN o.prefix_observation = 'C' THEN 1 ELSE 0 END ) as curva, 
        SUM( CASE WHEN o.prefix_observation = 'E' THEN 1 ELSE 0 END ) as velocidad, 
        SUM( CASE WHEN o.prefix_observation = 'F' THEN 1 ELSE 0 END ) as frenada 
 FROM   snapcar.trips t 
        INNER JOIN      snapcar.clients c on c.id = t.client_id 
        LEFT OUTER JOIN snapcar.trip_observations_no_deleted_view o ON o.trip_id = t.id 
 WHERE  round(t.distance/1000,2) > 0.3 
 AND    t.id = 159601
-- AND	  c.vehicle_id in (405,406,408)
-- AND    c.driver_id  = 184 
-- AND    t.from_date >= date_add( ?, interval 3 hour) 
-- AND    t.from_date <  date_add(date_add( ?, interval 3 hour), interval 1 day) 
 GROUP  BY t.id, c.vehicle_id, c.driver_id, t.from_date, t.to_date, t.distance, t.updated_at
 ORDER  BY from_date DESC;

select * from tEvento e where e.nIdViaje=159601;
select * from snapcar.trip_observations_no_deleted_view o where o.trip_id =159601;

-- Lista viajes desde la base de lucho
select * 
from snapcar.trips t join snapcar.clients c on c.id = t.client_id
where ( c.driver_id=77 or c.vehicle_id=203 )
-- and t.`status`='S'
order by from_date desc;
-- Permite modificar
select * 
from snapcar.trips t 
where t.client_id=485
and t.`status` in ('S','A')
order by from_date desc;

UPDATE snapcar.trips set UPDATED_AT=NOW()
where client_id=511
and `status` in ('S');
                
-- Lista viajes desde la base de lucho
select * 
from snapcar.control_files t join snapcar.clients c on c.id = t.client_id
where ( c.driver_id=77 or c.vehicle_id=203 )
-- and t.`status`='S'
order by event_date desc;
                
-- Verifica un viaje                
select * from tEvento where nIdViaje=269999 order by tEvento desc
limit 10000
;
select * 
from snapcar.trips t 
where t.id=269999
-- and t.`status` in ('S','A')
order by from_date desc
;
select * 
from snapcar.trip_details d
where d.trip_id=269999
order by d.event_date desc
;
                                