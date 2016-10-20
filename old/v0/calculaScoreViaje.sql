DROP PROCEDURE IF EXISTS calculaScoreViaje;
CREATE PROCEDURE calculaScoreViaje ()
BEGIN
	DECLARE kEventoInicio      integer DEFAULT 1;
	DECLARE kEventoFin         integer DEFAULT 2;
	DECLARE kEventoAceleracion integer DEFAULT 3;
	DECLARE kEventoFrenada     integer DEFAULT 4;
	DECLARE kEventoVelocidad   integer DEFAULT 5;

	BEGIN
		DECLARE dCount				date;
		DECLARE vnIdViaje			integer;
		DECLARE vfUsuario			integer;
		DECLARE vnKms				float;
		DECLARE vnPtjVelocidad		float;
		DECLARE vnPtjFrenada		float;
		DECLARE vnPtjAceleracion	float;
		DECLARE vnValor				float;

		DECLARE eofCurViaje integer DEFAULT 0;
		DECLARE curViaje CURSOR FOR
			 SELECT e.nIdViaje
			   FROM tEvento e
			  WHERE e.fTpEvento > kEventoFin
			    AND e.nIdViaje > 3
			  GROUP BY e.nIdViaje;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurViaje = 1;

		SELECT 'Inicio curViaje';
		OPEN  curViaje;
		FETCH curViaje INTO vnIdViaje;
		WHILE NOT eofCurViaje DO
			-- Calcula para el día
			SELECT nKms , nPtjVelocidad , nPtjFrenada , nPtjAceleracion
			  INTO vnKms, vnPtjVelocidad, vnPtjFrenada, vnPtjAceleracion
			  FROM vPuntaje
			 WHERE nIdViaje = vnIdViaje;

			IF vnKms IS NULL OR vnKms = 0 THEN
				SET vnKms = 0;
				SET vnValor = 100;
			ELSE
				SET vnValor = round(( vnPtjAceleracion + vnPtjFrenada + vnPtjVelocidad ) / 3, 2);
			END IF;

			UPDATE tEvento
			   SET nValor    = vnValor
			 WHERE nIdViaje  = vnIdViaje
			   AND fTpEvento = kEventoInicio;

			FETCH curViaje INTO vnIdViaje;
		END WHILE;
		CLOSE curViaje;
    SELECT 'Fin curViaje';
	END;

END;
