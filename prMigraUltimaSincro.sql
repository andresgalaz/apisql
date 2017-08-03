DELIMITER //
DROP PROCEDURE IF EXISTS prMigraUltimaSincro //
CREATE PROCEDURE prMigraUltimaSincro ( )
BEGIN
    -- Crea un atabla temporal con la última fecha de sincronización, viaje o control
    DROP TEMPORARY TABLE IF EXISTS wUltimaSincro;
    CREATE TEMPORARY TABLE wUltimaSincro AS
	SELECT	fVehiculo, max(tRegistroActual) tUltimaSincro
	FROM	score.tInicioTransferencia
    GROUP BY fVehiculo
	UNION ALL
	SELECT	fVehiculo, max(tEvento) 
	FROM	score.tEvento
    GROUP BY fVehiculo
	UNION ALL
	SELECT	c.vehicle_id, max(event_date)
	FROM	snapcar.control_files f 
			JOIN snapcar.clients c ON c.id = f.client_id
    GROUP BY c.vehicle_id;
    
	BEGIN
		DECLARE vfVehiculo			INTEGER;
		DECLARE vdUltimaSincro		DATE;
		-- Cursor Eventos por Viaje
		DECLARE eofCurSinc			INTEGER DEFAULT 0;
		DECLARE curSinc CURSOR FOR
			SELECT 	w.fVehiculo, max(w.tUltimaSincro) 
			FROM   	wUltimaSincro w
            GROUP BY fVehiculo;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurSinc = 1;

		OPEN  curSinc;
		FETCH curSinc INTO vfVehiculo, vdUltimaSincro;     
		WHILE NOT eofCurSinc DO
/*        
SELECT	vfVehiculo, vdUltimaSincro;
SELECT	count(*)
FROM	tScoreDia
WHERE	fVehiculo 	 = vfVehiculo
AND		dFecha 		>= vdUltimaSincro
AND		bSinMedicion = '1';
*/
			-- Anota medición a la tabla diaria
            UPDATE	tScoreDia
            SET		bSinMedicion = '0'
            WHERE	fVehiculo 	 = vfVehiculo
            AND		dFecha 		<= vdUltimaSincro
            AND		bSinMedicion = '1';
			FETCH curSinc INTO vfVehiculo, vdUltimaSincro;
		END WHILE;
		CLOSE curSinc;
	END; -- Fin cursor eventos

END //

