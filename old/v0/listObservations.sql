select ran.points, tri.prefix_observation, tri.client_id, tri.from_time
, tri.to_time, tri.observed_value
from trip_observations tri 
inner join observations_ranges ran on ran.id = tri.observation_range_id
left outer join streets str on str.id = tri.street_id