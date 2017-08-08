SET @USUARIO=102;
SELECT @USUARIO;
SELECT * FROM snapcar.control_files f join snapcar.clients c ON c.id=f.client_id where c.driver_id=@USUARIO;
SELECT * FROM snapcar.trips t join snapcar.clients c ON c.id=t.client_id where c.driver_id=@USUARIO;

call prControlCierreTransferencia();