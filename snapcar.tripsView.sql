USE snapcar;
DROP VIEW  IF EXISTS snapcar.trips_view;
CREATE VIEW snapcar.trips_view as
SELECT t.id							AS trip_id		, c.driver_id					AS driver_id	, c.vehicle_id					AS vehicle_id
	 , t.updated_at					AS updated_at	, round((t.distance / 1000),4)	AS distance		, t.from_date - interval 3 hour	AS from_date
     , t.to_date - interval 3 hour	AS to_date		
     , snapcar.fnNombreCalle( 'L', st.`name`, st.street_number, st.town,st.city, st.substate, st.state,st.country )	AS calle_inicio
     , snapcar.fnNombreCalle( 'C', st.`name`, st.street_number, st.town,st.city, st.substate, st.state,st.country )	AS calle_inicio_corta
     , snapcar.fnNombreCalle( 'L', se.`name`, se.street_number, se.town,se.city, se.substate, se.state,se.country )	AS calle_fin
     , snapcar.fnNombreCalle( 'C', se.`name`, se.street_number, se.town,se.city, se.substate, se.state,se.country )	AS calle_fin_corta
     , dIni.latitude 				AS latitude_ini	, dIni.longitude				AS longitude_ini, dFin.latitude					AS latitude_fin
     , dFin.longitude				AS longitude_fin
FROM   trips t
	   INNER JOIN	clients			c		ON c.id = t.client_id
	   INNER JOIN	trip_details	dIni	ON dIni.trip_id = t.id
										   AND dIni.event_date = t.from_date
	   INNER JOIN 	trip_details	dFin	ON dFin.trip_id = t.id
										   AND dFin.event_date = t.to_date
	   LEFT JOIN	g_streets		st		ON st.id = t.start_street_id
	   LEFT JOIN	g_streets		se		ON se.id = t.end_street_id
WHERE  t.status = 'S'
AND    t.distance > 300
-- AND	   EXISTS ( SELECT 1 FROM trip_details de WHERE de.trip_id = t.id AND de.speed_ms > 0 )
;
