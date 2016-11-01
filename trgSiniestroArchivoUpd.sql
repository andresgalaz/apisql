DROP TRIGGER IF EXISTS trgSiniestroArchivoUpd;
DELIMITER //
CREATE TRIGGER trgSiniestroArchivoUpd BEFORE UPDATE
    ON tSiniestroArchivo FOR EACH ROW
BEGIN
    SET NEW.tModif = now();
END //
DELIMITER ;
