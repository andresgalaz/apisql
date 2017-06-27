-- delete from trip_observations_g where trip_id in ( 5714,5735,5716,5742,5737,5724,5728,5709,5706,5736,5711,5719,5732,5723,5704,5731,5718,5707,5738,5733,5741,5730,5722 ) and prefix_observation = 'A';
	

select trip_id, prefix_observation, count(*) cantidad
from trip_observations_g
where from_time >= '2017-05-24'
group by trip_id, prefix_observation
order by cantidad desc

