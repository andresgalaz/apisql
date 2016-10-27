DROP TRIGGER IF EXISTS trgVehiculoIns;
DELIMITER //
CREATE TRIGGER trgVehiculoIns AFTER INSERT
    ON tVehiculo FOR EACH ROW
BEGIN
	INSERT INTO tUsuarioVehiculo ( pUsuario, pVehiculo, fUsuarioTitular )
	SELECT c.fUsuarioTitular, NEW.pVehiculo, c.fUsuarioTitular
	  FROM tCuenta c
	 WHERE c.pCuenta = NEW.fCuenta;
END //
DELIMITER ;
