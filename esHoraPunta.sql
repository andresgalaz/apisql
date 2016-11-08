DROP FUNCTION IF EXISTS esHoraPunta;
DELIMITER //
CREATE FUNCTION esHoraPunta (prmTime TIMESTAMP) RETURNS INTEGER
BEGIN
	-- Returno 1 si es hora punto, sino es cero
	DECLARE nHora INTEGER;

	SET nHora = HOUR( prmTime );
	IF	( nHora >= 0	AND nHora < 6	) OR ( nHora >= 7	AND nHora < 10 ) OR
		( nHora >= 17	AND nHora < 20	) OR ( nHora >= 22	AND nHora < 24 ) THEN
		-- Es hora punta
		RETURN 1;
	END IF;
	RETURN 0;
END //
DELIMITER ;
