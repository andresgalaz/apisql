DROP TRIGGER IF EXISTS trgVehiculoUpd;
DELIMITER //
CREATE TRIGGER trgVehiculoUpd BEFORE UPDATE
    ON tVehiculo FOR EACH ROW
BEGIN
    IF NEW.bVigente != '1' THEN
        DELETE FROM tUsuarioVehiculo
	    WHERE pVehiculo = OLD.pVehiculo;
    END IF;
END //
DELIMITER ;
