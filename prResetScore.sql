DROP PROCEDURE IF EXISTS prResetScore;
DELIMITER //
CREATE PROCEDURE prResetScore( in prm_dInicio DATE)
BEGIN
    -- Inicializa la tabla tScoreDia para todos los días a partir de mayo de 2016
	-- Parametros
	DECLARE vdDia				date DEFAULT prm_dInicio;
    
    WHILE vdDia < fnNow() DO
--      SELECT 'DIA', fnNow(), vdDia;
        CALL prCalculaScoreDiaInicio( vdDia );
	    SET vdDia = ADDDATE( vdDia, INTERVAL 1 DAY);
    END WHILE;

	SET vdDia = prm_dInicio;
    
    /*
    WHILE vdDia < fnNow() DO
        SELECT 'MES', fnNow(), vdDia;
        CALL prCalculaScoreMesInicio( vdDia );
--      SELECT 'CONDUCTOR', fnNow(), vdDia;
        CALL prCalculaScoreMesConductorInicio( vdDia );
	    SET vdDia = ADDDATE( vdDia, INTERVAL 1 MONTH);
    END WHILE;
    */
END //
DELIMITER ;
