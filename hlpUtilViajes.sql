SELECT t.id trip_id, t.client_id, c.vehicle_id, c.driver_id, 
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
 WHERE  round(t.distance/1000,2) > 0.3 
 AND    c.vehicle_id in (405,406,408)
-- AND    c.driver_id  = 184 
-- AND    t.from_date >= date_add( ?, interval 3 hour) 
-- AND    t.from_date <  date_add(date_add( ?, interval 3 hour), interval 1 day) 
 GROUP  BY t.id, c.vehicle_id, c.driver_id, t.from_date, t.to_date, t.distance 
 ORDER  BY from_date DESC;

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
                