USE snapcar;
DROP VIEW  IF EXISTS snapcar.trip_observations_view;
CREATE VIEW snapcar.trip_observations_view AS
SELECT t.id                     AS trip_id          , t.client_id              AS client_id
     , t.from_date              AS fecha_ini        , t.to_date                AS fecha_fin
     , t.distance               AS distance         , c.vehicle_id             AS vehicle_id
     , c.driver_id              AS driver_id        , o.prefix_observation     AS prefix
     , r.points                 AS puntos           , r.app_level			   AS app_level
	 , o.id						AS observation_id	, o.observed_value         AS obs_value
     , o.permited_value         AS permited_value   , o.from_time              AS obs_fecha
	 , snapcar.fnNombreCalle( 'L', so.name, so.street_number, so.town, so.city, so.substate, so.state, so.country ) AS calle
	 , snapcar.fnNombreCalle( 'C', so.name, so.street_number, so.town, so.city, so.substate, so.state, so.country ) AS calle_corta
	 , snapcar.fnNombreCalle( 'L', st.name, st.street_number, st.town, st.city, st.substate, st.state, st.country ) AS calle_inicio
	 , snapcar.fnNombreCalle( 'C', st.name, st.street_number, st.town, st.city, st.substate, st.state, st.country ) AS calle_inicio_corta
	 , snapcar.fnNombreCalle( 'L', se.name, se.street_number, se.town, se.city, se.substate, se.state, se.country ) AS calle_fin
	 , snapcar.fnNombreCalle( 'C', se.name, se.street_number, se.town, se.city, se.substate, se.state, se.country ) AS calle_fin_corta
     , d.latitude               AS latitude         , d.longitude              AS longitude
     , t.updated_at             AS ts_modif
 FROM  trips t
       join      clients c                           ON c.id            = t.client_id
       left join trip_observations_no_deleted_view o ON o.trip_id       = t.id
       left join virloc_observation_ranges r         ON r.id            = o.observation_range_id
       left join g_streets so                        ON so.id           = o.street_id
       left join g_streets st                        ON st.id           = t.start_street_id
       left join g_streets se                        ON se.id           = t.end_street_id
       left join trip_details d                      ON d.trip_id       = t.id
                                                    AND d.event_date    = o.from_time
 WHERE t.status = 'S'
 -- AGALAZ: No se envían al facturador ni a la API
 AND   r.points > 0
