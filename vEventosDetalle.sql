-- drop view score.vEventosDetalle;
create view score.vEventosDetalle as
select t.id id_viaje, t.from_date, t.to_date, t.distance / 1000 ditancia_km
     , IFNULL(o.prefix_observation, 'Sin eventos') tipoEvento, o.from_time, o.permited_value, o.observed_value
     , d.speed_kmh, d.virloc_event, d.latitude, d.longitude, d.x, d.y, d.z
     , c.vehicle_id, c.driver_id
from   trips t 
       inner join clients c on c.id = t.client_id
       inner join trip_observations_g o on o.trip_id = t.id
       left  join trip_details d on d.trip_id = o.trip_id
                                and d.event_date = o.from_time
-- where  c.driver_id = 111
-- and    t.from_date >= '2017-04-01'
order by t.from_date, o.from_time
