DELIMITER //
DROP TRIGGER IF EXISTS trgVehiculoInsBefore //
CREATE TRIGGER trgVehiculoInsBefore BEFORE INSERT
    ON score.tVehiculo FOR EACH ROW
BEGIN
	IF new.dIniVigencia IS NULL THEN
		SET new.dIniVigencia = DATE(NOW());
		SET new.dIniPoliza = DATE(NOW());
    END IF;
END;
