DROP PROCEDURE IF EXISTS prCalculaScoreMesConductorInicio;
DELIMITER //
CREATE PROCEDURE prCalculaScoreMesConductorInicio (in prmPeriodo date)
BEGIN
    -- Inicializa la tabla tScoreMesConductos, insertando un registro por mes por cada relación
    -- usuario / vehiculo de la tabla tUsuarioVehiculo. Este programa debe correr a las 0 hrs del
    -- primer día de cada mes
    
    DECLARE vdMes               date;
	-- Llaves
	DECLARE vpVehiculo			integer;
	DECLARE vpUsuario			integer;

    -- Ajusta al periodo
    SET vdMes = DATE(DATE_SUB(prmPeriodo, INTERVAL DAYOFMONTH(prmPeriodo) - 1 DAY));
    BEGIN    
        -- Cursor Vehiculos
        DECLARE eofCurVeh integer DEFAULT 0;
        DECLARE CurVeh CURSOR FOR
        	SELECT DISTINCT uv.pVehiculo, uv.pUsuario
        	FROM   tUsuarioVehiculo uv
            WHERE  uv.tActiva <= vdMes;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;
        OPEN  CurVeh;
        FETCH CurVeh INTO vpVehiculo, vpUsuario;
        WHILE NOT eofCurVeh DO
            CALL prCalculaScoreMesConductor( vdMes, vpVehiculo, vpUsuario );
        	FETCH CurVeh INTO vpVehiculo, vpUsuario;
        END WHILE;
        CLOSE CurVeh;
    END;
END //
DELIMITER ;
