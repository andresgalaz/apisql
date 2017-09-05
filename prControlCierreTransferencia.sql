DELIMITER //
DROP PROCEDURE IF EXISTS prControlCierreTransferencia //
CREATE PROCEDURE prControlCierreTransferencia ()
BEGIN
	CREATE TEMPORARY TABLE IF NOT EXISTS wMemoryCierreTransf (
		pVehiculo			INTEGER		UNSIGNED	NOT NULL,
		fUsuarioTitular		INTEGER		UNSIGNED	NOT NULL,
		cPatente			VARCHAR(20)				NOT NULL,
		tUltTransferencia	DATETIME	DEFAULT NULL,
		tUltViaje			DATETIME	DEFAULT NULL,
		tUltControl			DATETIME	DEFAULT NULL,
		dProximoCierre		DATE			 		NOT NULL,
		PRIMARY KEY (pVehiculo)
	) ENGINE=MEMORY;
    DELETE FROM wMemoryCierreTransf;

	-- Crea registro con la última transferencia
	INSERT INTO wMemoryCierreTransf
		  ( pVehiculo   , cPatente	, fUsuarioTitular	, dProximoCierre 
          , tUltTransferencia )
    SELECT 	it.fVehiculo, v.cPatente, v.fUsuarioTitular	, fnPeriodoActual( v.dIniVigencia, 1 )
		  , max(it.tRegistroActual) + INTERVAL -3 hour
    FROM 	score.tInicioTransferencia it 
			JOIN tVehiculo v ON v.pVehiculo = it.fVehiculo
	WHERE	v.bVigente = '1'
    GROUP BY it.fVehiculo, v.cPatente, v.fUsuarioTitular, v.dIniVigencia;
    
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
					  ( pVehiculo   , cPatente	, fUsuarioTitular	, dProximoCierre	
                      , tUltViaje	)
				SELECT 	v.pVehiculo	, v.cPatente, v.fUsuarioTitular	, fnPeriodoActual( v.dIniVigencia, 1 )
					  , vtUltViaje
				FROM 	tVehiculo v 
                WHERE	v.pVehiculo = vnVehicleId
				AND		v.bVigente = '1';
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
					  ( pVehiculo   , cPatente	, fUsuarioTitular	, dProximoCierre	
                      , tUltControl	)
				SELECT 	v.pVehiculo	, v.cPatente, v.fUsuarioTitular	, fnPeriodoActual( v.dIniVigencia, 1 )
					  , vtUltControl
				FROM 	tVehiculo v 
                WHERE	v.pVehiculo = vnVehicleId
				AND		v.bVigente = '1';
            ELSE
				UPDATE	wMemoryCierreTransf
				SET		tUltControl = vtUltControl
                WHERE	pVehiculo = vnVehicleId;
            END IF;
			FETCH cur INTO vnVehicleId, vpVehiculo, vtUltControl;
		END WHILE;
		CLOSE cur;
	END;

	-- Muestra el resultado
	SELECT w.fUsuarioTitular pUsuario, w.pVehiculo idVehiculo, w.cPatente, u.cEmail, u.cNombre
-- 		 , GREATEST(w.tUltTransferencia, w.tUltViaje, w.tUltControl ) fecUltTransferencia, w.tUltViaje fecUltViaje, w.tUltControl fecUltControl
		 , w.tUltTransferencia fecUltTransferencia, w.tUltViaje fecUltViaje, w.tUltControl fecUltControl
		 , greatest(w.tUltTransferencia, w.tUltViaje, w.tUltControl ) fecMaxima
		 , w.dProximoCierre, DATEDIFF(w.dProximoCierre,NOW()) nDiasAlCierre
	FROM	wMemoryCierreTransf w
			JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular
	ORDER BY nDiasAlCierre ;

END //