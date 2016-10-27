DROP TRIGGER IF EXISTS trgSiniestroSubIns;
DELIMITER //
CREATE TRIGGER trgSiniestroSubInsIns 
    BEFORE INSERT ON tSiniestroSub FOR 
    EACH ROW
BEGIN
	DECLARE nSub integer DEFAULT 1;

    SELECT IFNULL(MAX(pSub),0) + 1 
      INTO nSub
      FROM tSiniestroSub
     WHERE pSiniestro = NEW.pSiniestro;
    
    SET NEW.pSub := nSub;
END //
DELIMITER ;
