SET @USUARIO=102;
SELECT @USUARIO;
SELECT * FROM snapcar.control_files f join snapcar.clients c ON c.id=f.client_id where c.driver_id=@USUARIO;
SELECT * FROM snapcar.trips t join snapcar.clients c ON c.id=t.client_id where c.driver_id=@USUARIO;

-- Estado del Firmware
SELECT f.cEstado, v.cPatente, u.cEmail, u.cNombre, max(f.tModif) FROM score.tFirmwareEstado f left join tVehiculo v on v.pVehiculo = f.fVehiculo left join tUsuario u on u.pUsuario=v.fUsuarioTitular
group by f.cEstado, v.cPatente, u.cEmail, u.cNombre desc
order by 2;

call prControlCierreTransferencia();

