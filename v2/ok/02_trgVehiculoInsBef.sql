DELIMITER //
DROP TRIGGER IF EXISTS trgVehiculoInsBefore //
CREATE TRIGGER trgVehiculoInsBefore BEFORE INSERT
    ON score.tVehiculo FOR EACH ROW
BEGIN
    SET new.dIniVigencia = DATE(NOW());
END;
