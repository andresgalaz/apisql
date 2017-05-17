DROP PROCEDURE IF EXISTS prProcesaDeleted;
DELIMITER //
CREATE PROCEDURE prProcesaDeleted ()
BEGIN
	BEGIN
		-- Claves
		DECLARE vnIdViaje	integer;
		-- Cursor Eventos por Viaje
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
            SELECT ev.nIdViaje
            FROM   wEventoDeleted we
                   JOIN tTpEvento tp ON tp.cPrefijo = we.prefix_observation
                   JOIN tEvento  ev  ON ev.nIdViaje = we.trip_id
                                    AND tp.cPrefijo = we.prefix_observation
                                    AND ev.tEvento  = we.from_time + INTERVAL -3 HOUR
            GROUP BY ev.nIdViaje;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

		OPEN  CurEvento;
		FETCH CurEvento INTO vnIdViaje;
		WHILE NOT eofCurEvento DO
            -- SELECT 'Calcula viaje',vnIdViaje;
			-- Calcula Score diario
			CALL prCalculaScoreViaje( vnIdViaje );
			FETCH CurEvento INTO vnIdViaje;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
    
	BEGIN
		-- Claves
		DECLARE vpVehiculo	integer;
		DECLARE vpUsuario	integer;
		DECLARE vdFecha	    date;
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Usuario y Fecha de evento
		-- para calcular el score diario
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
            SELECT ev.fVehiculo, ev.fUsuario, date(ev.tEvento)
            FROM   wEventoDeleted we
                   JOIN tTpEvento tp ON tp.cPrefijo = we.prefix_observation
                   JOIN tEvento  ev  ON ev.nIdViaje = we.trip_id
                                    AND tp.cPrefijo = we.prefix_observation
                                    AND ev.tEvento  = we.from_time  + INTERVAL -3 HOUR
            GROUP BY ev.fVehiculo, ev.fUsuario, date(ev.tEvento);
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

        -- SELECT '610 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
        -- SELECT '620 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
            SELECT 'Calcula dia', vpVehiculo, vpUsuario, vdFecha;
			-- Calcula Score diario
			CALL prCalculaScoreDia( vdFecha, vpVehiculo, vpUsuario );
			FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
    
    -- Calcula Score Mensual, solo de los vehículos involucrados, viene después del
    -- cálculo diario porque para calcular el mensual, se utiliza la tabla tScoreDia
	BEGIN
		-- Claves
		DECLARE vpVehiculo	integer;
		DECLARE vcPeriodo	varchar(20);
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Periodo de evento (Dia uno del mes)
		-- para calcular el score mensual
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
            SELECT ev.fVehiculo, DATE(CONCAT(substr(ev.tEvento,1,7),'-01'))
            FROM   wEventoDeleted we
                   JOIN tTpEvento tp ON tp.cPrefijo = we.prefix_observation
                   JOIN tEvento  ev  ON ev.nIdViaje = we.trip_id
                                    AND tp.cPrefijo = we.prefix_observation
                                    AND ev.tEvento  = we.from_time  + INTERVAL -3 HOUR
            group by ev.fVehiculo, substr(ev.tEvento,1,7);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

        -- SELECT '710 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vcPeriodo;
        -- SELECT '720 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
            SELECT 'Calcula mes', vpVehiculo, vcPeriodo;
			-- Calcula Score Mensual
			CALL prCalculaScoreMes( vcPeriodo, vpVehiculo );
			FETCH CurEvento INTO vpVehiculo, vcPeriodo;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos

    -- Calcula Score Mensual por Conductor (usuario), solo de los usuarios involucrados
    -- viene después del cálculo diario porque se utiliza la tabla tScoreDia
	BEGIN
		-- Acumuladores
		DECLARE vpVehiculo	integer;
		DECLARE vpUsuario	integer;
		DECLARE vcPeriodo	varchar(20);
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Periodo de evento (Dia uno del mes)
		-- para calcular el score mensual
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
            SELECT ev.fVehiculo, ev.fUsuario, DATE(CONCAT(substr(ev.tEvento,1,7),'-01'))
            FROM   wEventoDeleted we
                   JOIN tTpEvento tp ON tp.cPrefijo = we.prefix_observation
                   JOIN tEvento  ev  ON ev.nIdViaje = we.trip_id
                                    AND tp.cPrefijo = we.prefix_observation
                                    AND ev.tEvento  = we.from_time  + INTERVAL -3 HOUR
            GROUP BY ev.fVehiculo, ev.fUsuario, substr(ev.tEvento,1,7);
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

        -- SELECT '810 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vpUsuario, vcPeriodo;
        -- SELECT '820 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
            SELECT 'Calcula mes conductor', vpVehiculo, vpUsuario, vcPeriodo;
			-- Calcula Score Mes por Condductor
			CALL prCalculaScoreMesConductor( vcPeriodo, vpVehiculo, vpUsuario );
			FETCH CurEvento INTO vpVehiculo, vpUsuario, vcPeriodo;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
    
END //
DELIMITER ;

