DELIMITER //
DROP PROCEDURE IF EXISTS prControlCierreTransferenciaInicioDef //
CREATE PROCEDURE prControlCierreTransferenciaInicioDef ( IN prm_nMesAvance INTEGER )
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS wMemoryCierreTransf (
		pVehiculo			INTEGER		UNSIGNED	NOT NULL,
        bVigente			BOOLEAN,
		fUsuarioTitular		INTEGER		UNSIGNED	NOT NULL,
		cPatente			VARCHAR(20)				NOT NULL,
		cPoliza				VARCHAR(40),
        dIniVigencia		DATE,
		tUltTransferencia	DATETIME	DEFAULT NULL,
		tUltViaje			DATETIME	DEFAULT NULL,
		tUltControl			DATETIME	DEFAULT NULL,
        nDiasNoSincro		INTEGER		UNSIGNED	DEFAULT 0 NOT NULL,
		dProximoCierre		DATE			 		NOT NULL,
        nDiasAlCierre		INTEGER					DEFAULT 0 NOT NULL,
		PRIMARY KEY (pVehiculo)
	) ENGINE=MEMORY;
    DELETE FROM wMemoryCierreTransf;

	-- Crea registro con la última transferencia
	INSERT INTO wMemoryCierreTransf
		  ( pVehiculo  , bVigente	, cPatente	, cPoliza	, dIniVigencia	, fUsuarioTitular	, dProximoCierre 
          , tUltTransferencia )
    SELECT 	v.pVehiculo, v.bVigente	, v.cPatente, v.cPoliza	, v.dIniVigencia, v.fUsuarioTitular
		  , fnPeriodoActual( v.dIniVigencia, prm_nMesAvance )
		  , IFNULL( max(it.tRegistroActual) + INTERVAL -3 hour, v.dIniVigencia )
	FROM 	tVehiculo v
			LEFT JOIN score.tInicioTransferencia it  ON it.fVehiculo = v.pVehiculo
-- 	WHERE	v.bVigente = '1' and v.cPoliza is not null
    GROUP BY v.pVehiculo, v.bVigente, v.cPatente, v.cPoliza, v.fUsuarioTitular, v.dIniVigencia;
        
    -- Crea o Actualiza registro con el último viaje
    BEGIN
		DECLARE vnVehicleId	INTEGER;
		DECLARE vpVehiculo	INTEGER;
		DECLARE vtUltViaje	TIMESTAMP;
		-- Cursor Vehiculos para borrar 
		DECLARE eofCur INTEGER DEFAULT 0;
		DECLARE cur CURSOR FOR
			SELECT	c.vehicle_id, w.pVehiculo, max(t.from_date) + INTERVAL -3 hour
			FROM 	snapcar.clients c 
					JOIN		snapcar.trips		t on t.client_id = c.id
                    LEFT JOIN	wMemoryCierreTransf	w on w.pVehiculo = c.vehicle_id
			GROUP BY c.vehicle_id, w.pVehiculo;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;
		OPEN cur;
		FETCH cur INTO vnVehicleId, vpVehiculo, vtUltViaje;
		WHILE NOT eofCur DO
			IF vpVehiculo IS NULL THEN
				INSERT INTO wMemoryCierreTransf
					  ( pVehiculo   , bVigente	, cPatente	, cPoliza	, dIniVigencia	, fUsuarioTitular	, dProximoCierre	
                      , tUltViaje	)
				SELECT 	v.pVehiculo	, v.bVigente, v.cPatente, v.cPoliza	, v.dIniVigencia, v.fUsuarioTitular	, fnPeriodoActual( v.dIniVigencia, prm_nMesAvance )
					  , vtUltViaje
				FROM 	tVehiculo v 
                WHERE	v.pVehiculo = vnVehicleId;
-- 				AND		v.bVigente = '1';
            ELSE
				UPDATE	wMemoryCierreTransf
				SET		tUltViaje = vtUltViaje
                WHERE	pVehiculo = vnVehicleId;
            END IF;
			FETCH cur INTO vnVehicleId, vpVehiculo, vtUltViaje;
		END WHILE;
		CLOSE cur;
	END;

    -- Crea o Actualiza registro con el último control
    BEGIN
		DECLARE vnVehicleId		INTEGER;
		DECLARE vpVehiculo		INTEGER;
		DECLARE vtUltControl	TIMESTAMP;
		-- Cursor Vehiculos para borrar 
		DECLARE eofCur INTEGER DEFAULT 0;
		DECLARE cur CURSOR FOR
			SELECT	c.vehicle_id, w.pVehiculo, max(f.event_date) + INTERVAL -3 hour
			FROM 	snapcar.clients c 
					JOIN		snapcar.control_files	f ON f.client_id = c.id            
                    LEFT JOIN	wMemoryCierreTransf		w ON w.pVehiculo = c.vehicle_id
			GROUP BY c.vehicle_id, w.pVehiculo;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;
		OPEN cur;
		FETCH cur INTO vnVehicleId, vpVehiculo, vtUltControl;
		WHILE NOT eofCur DO
			IF vpVehiculo IS NULL THEN
				INSERT INTO wMemoryCierreTransf
					  ( pVehiculo   , bVigente	, cPatente	, cPoliza	, dIniVigencia	, fUsuarioTitular	, dProximoCierre	
                      , tUltControl	)
				SELECT 	v.pVehiculo	, v.bVigente, v.cPatente, v.cPoliza	, v.dIniVigencia, v.fUsuarioTitular	, fnPeriodoActual( v.dIniVigencia, prm_nMesAvance )
					  , vtUltControl
				FROM 	tVehiculo v 
                WHERE	v.pVehiculo = vnVehicleId;
-- 				AND		v.bVigente = '1';
            ELSE
				UPDATE	wMemoryCierreTransf
				SET		tUltControl = vtUltControl
                WHERE	pVehiculo = vnVehicleId;
            END IF;
			FETCH cur INTO vnVehicleId, vpVehiculo, vtUltControl;
		END WHILE;
		CLOSE cur;
	END;

	-- Calcula los dias sin sincronizar y los días al cierre
    UPDATE	wMemoryCierreTransf
    SET		nDiasNoSincro = DATEDIFF( LEAST( DATE(NOW()), dProximoCierre )
                              , GREATEST( IFNULL(DATE( tUltTransferencia), '0000-00-00')
                                        , IFNULL(DATE( tUltViaje        ), '0000-00-00')
                                        , IFNULL(DATE( tUltControl      ), '0000-00-00')) )
		,	nDiasAlCierre = DATEDIFF(dProximoCierre,DATE(NOW())) + ( CASE WHEN TIMESTAMPDIFF(MONTH,dIniVigencia, dProximoCierre) < 1 THEN DAY(LAST_DAY(NOW())) ELSE 0 END );
END //

DROP PROCEDURE IF EXISTS prControlCierreTransferencia //
CREATE PROCEDURE prControlCierreTransferencia (IN prm_opcPoliza VARCHAR(40))
BEGIN
	/*
	 * Opción póliza:
	 * 'SI' : Se muestra los vehículos con póliza
	 * 'NO' : Se muestra los vehículos sin póliza
	 * 'TODOS' : Se muestra todos los vehículos
	 */
	IF prm_opcPoliza IS NULL THEN
		SET prm_opcPoliza = 'TODOS';
	END IF;
	-- Crea tabla temporal wMemoryCierreTransf
	CALL prControlCierreTransferenciaInicioDef(0);
    IF prm_opcPoliza = 'ANULADOS' THEN
		SELECT w.fUsuarioTitular pUsuario, w.pVehiculo idVehiculo, w.cPatente, w.cPoliza, w.dIniVigencia, u.cEmail, u.cNombre
			 , w.tUltTransferencia fecUltTransferencia, w.tUltViaje fecUltViaje, w.tUltControl fecUltControl
			 , greatest(w.tUltTransferencia, w.tUltViaje, w.tUltControl ) fecMaxima
			 , w.dProximoCierre
	--         Si la fecha de vigencia está dentro del mes que se está cerrando, no corresonde facturar aún, sino hasta el cierre, por eso se le suman los días
	--         del mes actual
	-- 		 , DATEDIFF(w.dProximoCierre,NOW()) + CASE WHEN TIMESTAMPDIFF(MONTH,w.dIniVigencia, w.dProximoCierre) <= 1 THEN DAY(LAST_DAY(NOW())) ELSE 0 END    nDiasAlCierre
			 , w.nDiasAlCierre
		FROM	wMemoryCierreTransf w
				JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular
		WHERE 	w.bVigente = '0' 
		ORDER BY nDiasAlCierre ;
    ELSEIF prm_opcPoliza = 'TODOS' THEN
		SELECT w.fUsuarioTitular pUsuario, w.pVehiculo idVehiculo, w.cPatente, w.cPoliza, w.dIniVigencia, u.cEmail, u.cNombre
			 , w.tUltTransferencia fecUltTransferencia, w.tUltViaje fecUltViaje, w.tUltControl fecUltControl
			 , greatest(w.tUltTransferencia, w.tUltViaje, w.tUltControl ) fecMaxima
			 , w.dProximoCierre
	--         Si la fecha de vigencia está dentro del mes que se está cerrando, no corresonde facturar aún, sino hasta el cierre, por eso se le suman los días
	--         del mes actual
	-- 		 , DATEDIFF(w.dProximoCierre,NOW()) + CASE WHEN TIMESTAMPDIFF(MONTH,w.dIniVigencia, w.dProximoCierre) <= 1 THEN DAY(LAST_DAY(NOW())) ELSE 0 END    nDiasAlCierre
			 , w.nDiasAlCierre
		FROM	wMemoryCierreTransf w
				JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular;
    ELSE
		SELECT w.fUsuarioTitular pUsuario, w.pVehiculo idVehiculo, w.cPatente, w.cPoliza, w.dIniVigencia, u.cEmail, u.cNombre
			 , w.tUltTransferencia fecUltTransferencia, w.tUltViaje fecUltViaje, w.tUltControl fecUltControl
			 , greatest(w.tUltTransferencia, w.tUltViaje, w.tUltControl ) fecMaxima
			 , w.dProximoCierre
	--         Si la fecha de vigencia está dentro del mes que se está cerrando, no corresonde facturar aún, sino hasta el cierre, por eso se le suman los días
	--         del mes actual
	-- 		 , DATEDIFF(w.dProximoCierre,NOW()) + CASE WHEN TIMESTAMPDIFF(MONTH,w.dIniVigencia, w.dProximoCierre) <= 1 THEN DAY(LAST_DAY(NOW())) ELSE 0 END    nDiasAlCierre
			 , w.nDiasAlCierre
		FROM	wMemoryCierreTransf w
				JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular
		WHERE 	w.bVigente = '1' 
		AND     (  ( 'SI' = prm_opcPoliza AND w.cPoliza IS NOT NULL ) 
				OR ( 'NO' = prm_opcPoliza AND w.cPoliza IS     NULL )
				)
		ORDER BY nDiasAlCierre ;
	END IF;
END //
