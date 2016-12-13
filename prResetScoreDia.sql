DROP PROCEDURE IF EXISTS prResetScoreDia;
DELIMITER //
CREATE PROCEDURE prResetScoreDia ()
BEGIN
-- Inicializa la tabla tScoreDia para todos los días a partir de mayo de 2016
	-- Parametros
	DECLARE vdDia				date DEFAULT '2016-05-01';
    
    WHILE vdDia < now() DO
        -- SELECT now(), vdDia;
        CALL prCalculaScoreDiaInicio( vdDia );
	    SET vdDia = ADDDATE( vdDia, INTERVAL 1 DAY);
    END WHILE;
END //
DELIMITER ;
