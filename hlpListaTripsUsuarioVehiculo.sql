select trips.id, trips.from_date + interval -3 hour `from_date`, trips.to_date  + interval -3 hour to_date, round(trips.distance / 1000,2) distanceKM, trips.main_street_id, streets.name, trips.status
, usr.pUsuario
, usr.cEmail, usr.cNombre
, veh.pVehiculo
, veh.cPatente, veh.bVigente, veh.fTpDispositivo
from trips inner join clients on clients.id = trips.client_id
    left outer join g_streets streets on streets.id = trips.main_street_id
    left outer join score.tUsuario usr on usr.pUsuario = clients.driver_id
    left outer join score.tVehiculo veh on veh.pVehiculo = clients.vehicle_id
where trips.from_date >= '2017-08-10 00:00:00'
and veh.cPatente in ('JNN585','PJT083') -- OR usr.cEmail = 'gonzalo@haras-sanpedro.com.ar' )
-- and trips.distance > 300
order by trips.from_date;

select max(trip_id), max(event_date) from trip_details;
select max(id), max(from_date) from trips;