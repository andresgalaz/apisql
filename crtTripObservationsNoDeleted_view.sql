drop view if exists trip_observations_no_deleted_view;
create view trip_observations_no_deleted_view as
select o.*
from trip_observations_g  o
where not exists ( select 1 from trip_observations_deleted d where d.id = o.id );