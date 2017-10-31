DROP TRIGGER IF EXISTS trgVehiculoUpd;
DELIMITER //
CREATE TRIGGER trgVehiculoUpd BEFORE UPDATE
    ON tVehiculo FOR EACH ROW
BEGIN
    IF NEW.bVigente != '1' THEN
        DELETE FROM tUsuarioVehiculo
	    WHERE pVehiculo = OLD.pVehiculo;
        
        IF OLD.tBaja = '0000-00-00 00:00:00' and NEW.tBaja = '0000-00-00 00:00:00' THEN
			SET NEW.tBaja = NOW();
        END IF;
    END IF;
    SET NEW.tModif = now();
END //
DELIMITER ;
