-- create table integrity.agv as 
select trips.id, trips.client_id, trips.from_date, trips.to_date, trips.distance, trips.main_street_id, streets.name, trips.status
, usr.pUsuario
, usr.cEmail, usr.cNombre
, veh.pVehiculo, veh.dIniVigencia
, veh.cPatente, veh.bVigente, veh.fTpDispositivo
from snapcar.trips
    inner join snapcar.clients on clients.id = trips.client_id
    left outer join snapcar.streets on streets.id = trips.main_street_id
    left outer join score.tUsuario usr on usr.pUsuario = clients.driver_id
    left outer join score.tVehiculo veh on veh.pVehiculo = clients.vehicle_id
where trips.from_date < veh.dIniVigencia
and clients.vehicle_id=392
and trips.status='S'
order by trips.from_date;

select trips.*
from snapcar.trips
where id in ( select id from integrity.agv )
order by trips.from_date;

update snapcar.trips set status='D' 
where id in ( select id from integrity.agv );

select max(trip_id), max(event_date) from trip_details;
select max(id), max(from_date) from trips;
