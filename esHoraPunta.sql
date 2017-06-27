DROP FUNCTION IF EXISTS esHoraPunta;
DELIMITER //
CREATE FUNCTION esHoraPunta (prmTime TIMESTAMP) RETURNS INTEGER
BEGIN
	-- Returna 1 si es hora punto (o Nocturna), sino es cero
	DECLARE nHora INTEGER;
	DECLARE nDiaSemana INTEGER;
	-- Nocturna toda la semana de 22 a 6(am) 
	-- Luneas a Viernes (dia 2 a 6 ): A la mañana de 7 a 10 y la vuelta de la tarde de 17 a 20
	-- Sábado (dia 7): A la mañana de 10 a 13 y la vuelta de la tarde de 18 a 21
	-- Domingo (dia 1 ) A la mañana de 10 a 13 y la vuelta de la tarde de 18 a 21
	SET nHora = HOUR( prmTime );
	-- Nocturna
	IF	( nHora >= 22	AND nHora < 24 ) OR ( nHora >= 0 AND nHora < 6 ) THEN
		RETURN 1;
	END IF;

	SET nDiaSemana = dayOfWeek(prmTime);
	-- Sábado y Domingo
	IF ( nDiaSemana = 1 OR nDiaSemana = 7 ) THEN
		IF ( nHora >= 10 AND nHora < 13 ) OR ( nHora >= 18 AND nHora < 21 ) THEN
			-- Es hora punta
			RETURN 1;
		END IF;
	END IF;
	-- Resto de la semana
	IF ( nHora >= 7	AND nHora < 10 ) OR ( nHora >= 17 AND nHora < 20 ) THEN
		-- Es hora punta
		RETURN 1;
	END IF;
	-- No es hora punta ni nocturna
	RETURN 0;
END //
DELIMITER ;
