select client_id,count(*) from trips group by client_id;
select trip_id,count(*) from trip_observations group by trip_id order by 2 desc;
