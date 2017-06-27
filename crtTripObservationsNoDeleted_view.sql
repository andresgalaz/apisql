DROP VIEW IF EXISTS trip_observations_no_deleted_view;
CREATE VIEW trip_observations_no_deleted_view as
SELECT o.*
FROM trip_observations_g  o
WHERE NOT EXISTS ( SELECT 1 FROM trip_observations_deleted d WHERE d.id = o.id );