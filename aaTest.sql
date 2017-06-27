DELIMITER //
DROP PROCEDURE IF EXISTS aaTest//
CREATE PROCEDURE aaTest(in prm_ini integer, in prm_fin integer)
BEGIN
	DECLARE vnUsuario				integer DEFAULT prm_ini;
    
    WHILE vnUsuario <= prm_fin DO
        SELECT vnUsuario as USUARIO, now();
        CALL prBorraUsuario_( vnUsuario );
	    SET vnUsuario = vnUsuario + 1;
    END WHILE;
END //
DELIMITER ;
