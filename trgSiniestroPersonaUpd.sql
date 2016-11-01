DROP TRIGGER IF EXISTS trgSiniestroPersonaUpd;
DELIMITER //
CREATE TRIGGER trgSiniestroPersonaUpd BEFORE UPDATE
    ON tSiniestroPersona FOR EACH ROW
BEGIN
    SET NEW.tModif = now();
END //
DELIMITER ;
