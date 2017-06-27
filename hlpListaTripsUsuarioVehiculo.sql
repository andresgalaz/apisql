select trips.id, trips.from_date, trips.to_date, trips.distance, trips.main_street_id, streets.name, trips.status
, usr.pUsuario
, usr.cEmail, usr.cNombre
, veh.pVehiculo
, veh.cPatente, veh.bVigente, veh.fTpDispositivo
from trips inner join clients on clients.id = trips.client_id
    left outer join streets on streets.id = trips.main_street_id
    left outer join score.tUsuario usr on usr.pUsuario = clients.driver_id
    left outer join score.tVehiculo veh on veh.pVehiculo = clients.vehicle_id
where trips.from_date >= '2017-05-23 00:00:00'
order by trips.distance;

select max(trip_id), max(event_date) from trip_details;
select max(id), max(from_date) from trips;