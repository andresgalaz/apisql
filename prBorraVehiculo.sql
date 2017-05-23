DELIMITER //
DROP PROCEDURE IF EXISTS prBorraVehiculo //
CREATE PROCEDURE prBorraVehiculo ( in prm_pUsuario integer, in prm_pVehiculo integer  )
BEGIN
    DECLARE vfUsuarioTitular INTEGER;
    
    SELECT distinct fUsuarioTitular
    INTO   vfUsuarioTitular
    FROM   tUsuarioVehiculo 
    WHERE  pVehiculo = prm_pVehiculo;
    
    IF vfUsuarioTitular = prm_pUsuario THEN
        -- El usuario es titular, se borra toda la información del vehículo
        DELETE FROM tUsuarioVehiculo        WHERE  pVehiculo = prm_pVehiculo;
        DELETE FROM tAuditoria              WHERE  fVehiculo = prm_pVehiculo;
        DELETE FROM tEvento                 WHERE  fVehiculo = prm_pVehiculo;
        DELETE FROM tInicioTransferencia    WHERE  fVehiculo = prm_pVehiculo;
        DELETE FROM tVehiculoDesconectado   WHERE  pVehiculo = prm_pVehiculo;
        BEGIN    
            DECLARE vpSiniestro integer;
            -- Cursor Siniestro
            DECLARE eofCurSin integer DEFAULT 0;
            DECLARE CurSin CURSOR FOR
            	SELECT s.pSiniestro
                FROM   tSiniestro s
                WHERE  s.fVehiculo = prm_pVehiculo;
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
            DELETE FROM tSiniestro WHERE  fVehiculo = prm_pVehiculo;
        END;
        DELETE FROM tVehiculo WHERE  pVehiculo = prm_pVehiculo;
    ELSE
        -- El usuario no es titular, se borra solo la información del usuario relacionada al vehículo
        DELETE FROM tUsuarioVehiculo        WHERE  pUsuario = prm_pUsuario AND pVehiculo = prm_pVehiculo;
        DELETE FROM tEvento                 WHERE  fUsuario = prm_pUsuario AND fVehiculo = prm_pVehiculo;
        BEGIN    
            DECLARE vpSiniestro integer;
            -- Cursor Siniestro
            DECLARE eofCurSin integer DEFAULT 0;
            DECLARE CurSin CURSOR FOR
            	SELECT s.pSiniestro
                FROM   tSiniestro s
                WHERE  s.fUsuario  = prm_pUsuario
                AND    s.fVehiculo = prm_pVehiculo;
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
            DELETE FROM tSiniestro WHERE fUsuario = prm_pUsuario AND fVehiculo = prm_pVehiculo;
        END;
    END IF;
END //

DELIMITER ;
