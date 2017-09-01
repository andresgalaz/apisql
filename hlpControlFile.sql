SET @USUARIO=77;
SET @VEH=295;

select * from tVehiculo where pVehiculo=@VEH or cPatente='LTA765';
SELECT * FROM score.tFirmwareEstado where fVehiculo=@VEH;

SELECT @USUARIO;
SELECT c.driver_id, c.vehicle_id, f.event_date + INTERVAL -3 hour FROM snapcar.control_files f join snapcar.clients c ON c.id=f.client_id 
where c.driver_id=@USUARIO
AND f.event_date > now() + INTERVAL -50 day
ORDER BY f.event_date desc;
SELECT * FROM snapcar.trips t join snapcar.clients c ON c.id=t.client_id where c.driver_id=@USUARIO;

-- Estado del Firmware
SELECT f.cEstado, v.cPatente, u.cEmail, u.cNombre, max(f.tModif) FROM score.tFirmwareEstado f left join tVehiculo v on v.pVehiculo = f.fVehiculo left join tUsuario u on u.pUsuario=v.fUsuarioTitular
group by f.cEstado, v.cPatente, u.cEmail, u.cNombre desc
order by 2;

call prControlCierreTransferencia();

