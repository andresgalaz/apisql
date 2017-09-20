DELIMITER //
DROP PROCEDURE IF EXISTS prBorraUsuario //
CREATE PROCEDURE prBorraUsuario (in prm_pUsuario integer, in prm_bVehiculos integer )
BEGIN
    -- Si se indica prn_bVehiculos = true (1), se borran todos los vehiculos del usuario
    IF prm_bVehiculos = 1 THEN
        BEGIN    
    	    DECLARE vpVehiculo integer;
            -- Cursor Vehiculos para borrar 
            DECLARE eofCurVeh integer DEFAULT 0;
            DECLARE CurVeh CURSOR FOR
            	SELECT v.pVehiculo
                FROM   tVehiculo v
                WHERE  v.fUsuarioTitular = prm_pUsuario;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;
            OPEN  CurVeh;
            FETCH CurVeh INTO vpVehiculo;
            WHILE NOT eofCurVeh DO
                call prBorraVehiculo( prm_pUsuario, vpVehiculo );
            	FETCH CurVeh INTO vpVehiculo;
            END WHILE;
            CLOSE CurVeh;
        END;
    END IF;
    -- Borra siniestros como conductor
    BEGIN    
        DECLARE vpSiniestro integer;
        -- Cursor Siniestro
        DECLARE eofCurSin integer DEFAULT 0;
        DECLARE CurSin CURSOR FOR
        	SELECT s.pSiniestro
            FROM   tSiniestro s
            WHERE  s.fUsuario = prm_pUsuario;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurSin = 1;
        OPEN  CurSin;
        FETCH CurSin INTO vpSiniestro;
        WHILE NOT eofCurSin DO
            DELETE FROM tSiniestroArchivo   WHERE fSiniestro = vpSiniestro;
            DELETE FROM tSiniestroDano      WHERE pSiniestro = vpSiniestro;
            DELETE FROM tSiniestroPersona   WHERE pSiniestro = vpSiniestro;
            DELETE FROM tSiniestroSubDano   WHERE pSiniestro = vpSiniestro;
            DELETE FROM tSiniestroSub       WHERE pSiniestro = vpSiniestro;
            FETCH CurSin INTO vpSiniestro;
        END WHILE;
        DELETE FROM tSiniestro WHERE fUsuario = prm_pUsuario;
    END;
    
    -- No va a poder borrar si no están todos los vehículo borrados    
    DELETE FROM tNotificacionUsuario	WHERE  pUsuario		   = prm_pUsuario;
    DELETE FROM tVehiculo        		WHERE  fUsuarioTitular = prm_pUsuario;
    DELETE FROM tEvento       		   	WHERE  fUsuario        = prm_pUsuario;    
    DELETE FROM tSiniestro       		WHERE  fUsuario        = prm_pUsuario;
    DELETE FROM tCuenta          		WHERE  fUsuarioTitular = prm_pUsuario;
    DELETE FROM tAppEstado       		WHERE  fUsuario        = prm_pUsuario;
    DELETE FROM tUsuario        		WHERE  pUsuario        = prm_pUsuario;
END //

DELIMITER ;
