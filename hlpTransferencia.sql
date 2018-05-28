SET @idVeh = 428;
-- SET @idCli = -1;

select id INTO @idCli from snapcar.clients
WHERE vehicle_id=@idVeh
;

SELECT *
FROM score.tInicioTransferencia
WHERE fVehiculo=@idVeh
order by tRegistroActual desc
;
SELECT * FROM snapcar.control_files
WHERE client_id=@idCli
order by event_date desc
;
select * from snapcar.trips where client_id=@idCli
order by id desc
limit 10000
;