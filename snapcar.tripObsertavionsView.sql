USE snapcar;
DROP VIEW  IF EXISTS trip_observations_view;
create view trip_observations_view as
select t.id                     AS trip_id          , t.client_id              AS client_id
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
     , d.latitude               AS latitude         , d.longitude              AS longitude
     , t.updated_at             AS ts_modif 
  from trips t
       join      clients c                           on c.id            = t.client_id
       left join trip_observations_no_deleted_view o on o.trip_id       = t.id
       left join virloc_observation_ranges r         on r.id            = o.observation_range_id
       left join g_streets so                        on so.id           = o.street_id
       left join g_streets st                        on st.id           = t.main_street_id
       left join trip_details d                      on d.trip_id       = t.id 
                                                    and d.event_date    = o.from_time
