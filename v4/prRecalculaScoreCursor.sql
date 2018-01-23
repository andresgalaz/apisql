DELIMITER //
DROP PROCEDURE IF EXISTS prRecalculaScoreCursor //
CREATE PROCEDURE prRecalculaScoreCursor( in prm_dInicio DATE )
BEGIN
	DECLARE vpVehiculo	INTEGER;
	DECLARE vpUsuario	INTEGER;
	DECLARE eofCur		INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR
		SELECT uv.pVehiculo, uv.pUsuario
		FROM	tUsuarioVehiculo uv;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;

	OPEN cur;
	FETCH cur INTO vpVehiculo, vpUsuario;
	WHILE NOT eofCur DO
		call prRecalculaScore( prm_dInicio, vpVehiculo, vpUsuario );
		FETCH cur INTO vpVehiculo, vpUsuario;
	END WHILE;	
END //

DROP PROCEDURE IF EXISTS prRecalculaScoreFromFecha //
CREATE PROCEDURE prRecalculaScoreFromFecha( in prm_dInicio DATE )
BEGIN
	DECLARE dAct DATE DEFAULT prm_dInicio;
	WHILE dAct <= fnNow() DO
    select 'Inicio', dAct;
		call prCalculaScoreDiaInicio( dAct );
		call prRecalculaScoreCursor( dAct );
    select 'Fin', dAct;
		SET dAct = dAct + INTERVAL 1 DAY;
	END WHILE;	
END //


