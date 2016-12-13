DROP PROCEDURE IF EXISTS prCalculaScoreMesInicio;
DELIMITER //
CREATE PROCEDURE prCalculaScoreMesInicio (in prmPeriodo date)
BEGIN
    -- Inicializa la tabla tScoreMes, insertando un registro por mes por cada vehículo con
    -- una relación vigente usuario / vehiculo de la tabla tUsuarioVehiculo. Este programa 
    -- debe correr a las 0 hrs del primer día de cada mes
	DECLARE vdMes               date;
	DECLARE vpVehiculo			integer;
    -- Ajusta al periodo
    SET vdMes	  = DATE(DATE_SUB(prmPeriodo, INTERVAL DAYOFMONTH(prmPeriodo) - 1 DAY));
    BEGIN    
        -- Cursor Vehiculos
        DECLARE eofCurVeh integer DEFAULT 0;
        DECLARE CurVeh CURSOR FOR
        	SELECT DISTINCT uv.pVehiculo
        	FROM   tUsuarioVehiculo uv
            WHERE  uv.tActiva <= vdMes;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;
        OPEN  CurVeh;
        FETCH CurVeh INTO vpVehiculo;
        WHILE NOT eofCurVeh DO
            CALL prCalculaScoreMes( vdMes, vpVehiculo );
        	FETCH CurVeh INTO vpVehiculo;
        END WHILE;
        CLOSE CurVeh;
    END;
END //
DELIMITER ;
