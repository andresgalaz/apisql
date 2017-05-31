-- drop table if exists score.agv;
-- create table score.agv as 
select od.*, o.id id_g, o.from_time from_time_g, t.id trip_id, c.vehicle_id vehicle_id_g, c.driver_id driver_id_g
from trip_observations_deleted od
left join trip_observations_g o on o.id = od.id
        left join trips   t on t.id = o.trip_id
        left join clients c on c.id = t.client_id
where o.id is null
limit 20;

select agv.id, agv.deleted_at, agv.vehicle_id, agv.driver_id, agv.from_time
     , o.id id_g, o.from_time from_time_g, t.id trip_id_g, c.vehicle_id vehicle_id_g, c.driver_id driver_id_g
from score.agv agv
        inner join clients c on c.vehicle_id = agv.vehicle_id and c.driver_id = agv.driver_id
        inner join trips   t on t.client_id = c.id
        inner join trip_observations_g o on o.trip_id = t.id and o.from_time = agv.from_time
limit 20;

update trip_observations_deleted 
set driver_id = ( select c.driver_id
                  from trip_observations_g o
                  inner join trips   t on t.id = o.trip_id
                  inner join clients c on c.id = t.client_id
                  where o.id = trip_observations_deleted.id );
where od.id = 32046

