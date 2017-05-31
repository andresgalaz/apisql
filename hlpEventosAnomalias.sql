-- delete from trip_observations_g where trip_id in ( 5714,5716,5709,5706,5711,5704,5707,5718 ) and prefix_observation = 'A';
select trip_id, prefix_observation, count(*) cantidad
from trip_observations_g
where from_time >= '2017-05-24'
group by trip_id, prefix_observation
order by cantidad desc

