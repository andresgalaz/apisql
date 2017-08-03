DROP PROCEDURE IF EXISTS prRecalculaScore;
DELIMITER //
CREATE PROCEDURE prRecalculaScore( in prm_dInicio DATE, in prm_fVehiculo INTEGER, in prm_fUsuario INTEGER)
BEGIN
    -- Inicializa la tabla tScoreDia para todos los días a partir de mayo de 2016
	-- Parametros
	DECLARE vdDia				date DEFAULT prm_dInicio;
    DECLARE cDias               text DEFAULT prm_dInicio;
    
    WHILE vdDia < now() DO
        SET cDias = concat( cDias, substring(vdDia, 8 ));
        CALL prCalculaScoreDia( vdDia, prm_fVehiculo, prm_fUsuario );
	    SET vdDia = ADDDATE( vdDia, INTERVAL 1 DAY);
    END WHILE;
    -- SELECT prm_fVehiculo, prm_fUsuario, cDias;

	SET vdDia = prm_dInicio;
    
    WHILE vdDia < now() DO
        -- SELECT prm_fVehiculo, prm_fUsuario, vdDia;
        CALL prCalculaScoreMes( vdDia, prm_fVehiculo );
        CALL prCalculaScoreMesConductor( vdDia, prm_fVehiculo, prm_fUsuario );
	    SET vdDia = ADDDATE( vdDia, INTERVAL 1 MONTH);
    END WHILE;
END //
DELIMITER ;
