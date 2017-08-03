DROP PROCEDURE IF EXISTS prRecalculaScoreCursor;
DELIMITER //
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
DELIMITER ;
