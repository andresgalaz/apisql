DROP TRIGGER IF EXISTS trgCuentaUpd;
DELIMITER //
CREATE TRIGGER trgCuentaUpd BEFORE UPDATE
    ON tCuenta FOR EACH ROW
BEGIN
    SET NEW.tModif = now();
END //
DELIMITER ;
