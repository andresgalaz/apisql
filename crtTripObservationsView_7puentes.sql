DROP VIEW  IF EXISTS trip_observations_view;
create view trip_observations_view as
select t.id                     AS trip_id          , t.client_id              AS client_id
     , t.from_date              AS fecha_ini        , t.to_date                AS fecha_fin
     , t.distance               AS distance         , c.vehicle_id             AS vehicle_id
     , c.driver_id              AS driver_id        , o.prefix_observation     AS prefix
     , r.points                 AS puntos           , o.observed_value         AS obs_value
     , o.permited_value         AS permited_value   , o.from_time              AS obs_fecha
     , ( case
           when isnull(so.display_name) then so.name
           else so.display_name
         end )                  AS calle
     , ( case
           when isnull(st.display_name) then st.name
           else st.display_name
         end
       )                        AS calle_inicio
     , d.latitude               AS latitude         , d.longitude              AS longitude
     , t.updated_at             AS ts_modif 
  from trips t
       join      clients c               on c.id            = t.client_id
       left join trip_observations_g o   on o.trip_id       = t.id
--     left join trip_observations   o   on o.trip_id       = t.id
       left join observation_ranges r    on r.id            = o.observation_range_id
       left join streets so              on so.id           = o.street_id
       left join streets st              on st.id           = t.main_street_id
       left join trip_details d          on d.trip_id       = t.id 
                                        and d.event_date    = o.from_time