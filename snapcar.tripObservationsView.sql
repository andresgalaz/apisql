USE snapcar;
DROP VIEW  IF EXISTS snapcar.trip_observations_view;
CREATE VIEW snapcar.trip_observations_view as
SELECT o.id						AS observation_id	, o.trip_id
	 , o.prefix_observation							, o.observed_value
     , o.permited_value								, o.updated_at
     , o.from_time		- INTERVAL 3 HOUR	AS from_time
     , o.to_time		- INTERVAL 3 HOUR	AS to_time
     , CAST(r.points	AS UNSIGNED)		AS points
     , CAST(r.app_level AS UNSIGNED)		AS app_level
	 , snapcar.fnNombreCalle( 'L', so.name, so.street_number, so.town, so.city, so.substate, so.state, so.country ) AS calle
	 , snapcar.fnNombreCalle( 'C', so.name, so.street_number, so.town, so.city, so.substate, so.state, so.country ) AS calle_corta
     , d.latitude               AS latitude         , d.longitude              AS longitude
     , snapcar.fnFuerzaG( o.prefix_observation, d.x, d.y ) nFuerzaG
FROM   trip_observations_g					o
       INNER JOIN trip_details				d	ON d.trip_id	= o.trip_id 
											   AND d.event_date	= o.from_time
                                               AND d.speed_ms   > 0 
       LEFT  JOIN g_streets					so	ON so.id		= o.street_id
       LEFT  JOIN virloc_observation_ranges	r	ON r.id			= o.observation_range_id
                                   
WHERE NOT EXISTS( SELECT 1 FROM trip_observations_deleted d WHERE d.id = o.id )
AND o.`status` = 'OK'
;

SELECT * FROM snapcar.trip_observations_view
WHERE from_time > now() - interval 2 day
LIMIT 10
;
