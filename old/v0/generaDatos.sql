DROP PROCEDURE IF EXISTS generaDatos;
CREATE PROCEDURE generaDatos( IN vfUsuario int, IN vfVehiculo int, IN vtEventoIni timestamp )
BEGIN
	DECLARE nPosLon			double	DEFAULT -34.544070;
	DECLARE nPosLat			double	DEFAULT -58.532734;
	DECLARE nDeltaPaso		double	DEFAULT -0.001012;
	DECLARE bIniViaje		int		DEFAULT 0;
	DECLARE bFinViaje		int		DEFAULT 0;
	DECLARE nDado			double;
	DECLARE nRandLargoViaje	double;
	DECLARE nPasos			int		DEFAULT 0;
	DECLARE nDuracionSec	int		DEFAULT 0;
	DECLARE vnIdViaje		int;
	DECLARE vtEvento		timestamp;
	DECLARE vfTpEvento		int;
	DECLARE vnVelMaxima		int;
	DECLARE vnDistancia	double DEFAULT 0;
	DECLARE vnValor			double;
    
	SET nRandLargoViaje = rand() * 1.5 + 98.4;
  
	SELECT max(nIdViaje)+1 INTO vnIdViaje
	FROM   tEvento;
	-- Si no se definio tiempo de partida se el anterior mas un día
	IF vtEventoIni IS NULL THEN
		-- Un dìa +/- 15 minutos
		SET nDado = rand() * 30 + 1440 - 15;
		SELECT adddate(max(tEvento), INTERVAL nDado minute) INTO vtEventoIni 
		FROM   tEvento
		WHERE  fUsuario = vfUsuario AND fVehiculo = vfVehiculo;
	END IF;

	WHILE NOT bIniViaje DO
		SET nDado = rand() * 100;
		IF nDado > 96 THEN
			SET bIniViaje = 1;
		END IF;
		-- Avanza paso Long
		SET nDado = rand() * 100;
		IF nDado > 50 THEN
			SET nPosLon = nPosLon - nDeltaPaso;
		END IF;
		IF nDado > 95 THEN
			SET nPosLon = nPosLon - nDeltaPaso * 2;
		END IF;
		-- Avanza paso Lat
		SET nDado = rand() * 100;
		IF nDado > 50 THEN
			SET nPosLat = nPosLat + nDeltaPaso;
		END IF;
		IF nDado > 95 THEN
			SET nPosLat = nPosLat + nDeltaPaso * 2;
		END IF;
	END WHILE;

--	SELECT vnIdViaje, 1, nPasos, nRandLargoViaje, vtEventoIni, round(nPosLon,6) as `long`, round(nPosLat,6) as `lat`;
	INSERT INTO tEvento 
			( nIdViaje			, nIdTramo			, fTpEvento		, tEvento  
			, nLG				, nLT				, cCalle
			, nVelocidadMaxima	, nValor			, fVehiculo		, fUsuario
			, nPuntaje 			)
	VALUES	( vnIdViaje			, 1					, 1				, vtEventoIni
			, round(nPosLon,6)	, round(nPosLat,6)	, 'EN CONSTRUCCION'
			, NULL				, 0					, vfVehiculo	, vfUsuario
			, 0					);

	WHILE NOT bFinViaje DO
		-- Al menos 40 pasos antes de terminar
		SET nDado = rand() * 100;
		IF nDado > nRandLargoViaje AND nPasos > 40 THEN
			SET bFinViaje = 1;
		END IF;
		-- Cuenta pasos
		SET nPasos = nPasos + 1;
		-- Acumula tiempo entre 10 y 20 segundos por paso
		SET nDuracionSec = nDuracionSec + (rand() * 10 + 10 );
		-- Avanza paso Long
		SET nDado = rand() * 100;
		IF nDado > 50 THEN
			SET nPosLon = nPosLon - nDeltaPaso;
      SET vnDistancia = vnDistancia + 0.1;
		END IF;
		IF nDado > 95 THEN
			SET nPosLon = nPosLon - nDeltaPaso * 2;
      SET vnDistancia = vnDistancia + 0.2;
		END IF;
		-- Avanza paso Lat
		SET nDado = rand() * 100;
		IF nDado > 50 THEN
			SET nPosLat = nPosLat + nDeltaPaso;
      SET vnDistancia = vnDistancia + 0.1;
		END IF;
		IF nDado > 95 THEN
			SET nPosLat = nPosLat + nDeltaPaso * 2;
      SET vnDistancia = vnDistancia + 0.2;
		END IF;
		-- Genera Evento
		SET nDado = rand() * 1000;
		IF nDado > 970 THEN
			SET vtEvento = adddate(vtEventoIni, INTERVAL nDuracionSec SECOND);
			SET vfTpEvento = round(rand()*2.9+2.5);
			CASE vfTpEvento
				WHEN 3 THEN -- Aceleración
					SET vnVelMaxima = null;
					-- de 8 a 20 km/h/s
					SET vnValor		= round(rand()*12+8,1);
				WHEN 4 THEN -- Frenada
					SET vnVelMaxima = null;
					-- de 12 a 32 km/h/s
					SET vnValor		= round(rand()*20+12,1);
				WHEN 5 THEN -- Exceso Velocidad
					SET vnVelMaxima = round(rand()*90+40,-1);
					SET vnValor		= vnVelMaxima + round(rand()*50,1);
			END CASE;

--			SELECT vnIdViaje, vfTpEvento, nPasos, nRandLargoViaje, vtEvento, round(nPosLon,6) as `long`, round(nPosLat,6) as `lat`;
			INSERT INTO tEvento 
					( nIdViaje			, nIdTramo			, fTpEvento		, tEvento
					, nLG				, nLT				, cCalle
					, nVelocidadMaxima	, nValor			, fVehiculo		, fUsuario
					, nPuntaje			)
			VALUES	( vnIdViaje			, 1					, vfTpEvento	, vtEvento 
					, round(nPosLon,6)	, round(nPosLat,6)	, 'EN CONSTRUCCION'
					, vnVelMaxima		, vnValor			, vfVehiculo	, vfUsuario
					, 0					);
		END IF;     
	END WHILE;
	
	SET vtEvento = adddate(vtEventoIni, INTERVAL nDuracionSec SECOND);
--	SELECT vnIdViaje, 2, nPasos, nRandLargoViaje, vtEvento, nDuracionSec, adddate(vtEventoIni, INTERVAL nDuracionSec SECOND);
	INSERT INTO tEvento 
			( nIdViaje			, nIdTramo			, fTpEvento	, tEvento
			, nLG				, nLT				, cCalle
			, nVelocidadMaxima	, nValor			, fVehiculo	, fUsuario
			, nPuntaje			)
	VALUES	( vnIdViaje			, 1					, 2			, vtEvento 
			, round(nPosLon,6)	, round(nPosLat,6)	, 'EN CONSTRUCCION'
			, NULL				, round(vnDistancia,2)			, vfVehiculo, vfUsuario
			, 0					);
END;
