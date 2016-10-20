DROP PROCEDURE IF EXISTS calculaScoreMesViaje;
DELIMITER //
CREATE PROCEDURE calculaScoreMesViaje (in prmMes date)
BEGIN
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;

	DECLARE dMes				date;
	DECLARE dMesSgte			date;
	DECLARE dProceso			date;
	DECLARE vnTotalDias         integer;
	DECLARE nFactorDias         float;

	-- Asegura que la fecha sea el primer día del Mes y sin Hora
	SET dMes	 = DATE(DATE_SUB(prmMes, INTERVAL DAYOFMONTH(prmMes) - 1 DAY));
	SET dMesSgte = ADDDATE(dMes, INTERVAL 1 MONTH);
	SET dProceso = DATE(NOW());

	IF dMesSgte > dProceso THEN
		-- No es mes completo
		SET vnTotalDias = DATEDIFF( dProceso, dMes ) + 1;
	ELSE
		-- Mes completo
		SET vnTotalDias = DATEDIFF( dMesSgte, dMes );
	END IF;
	SET nFactorDias = vnTotalDias / DATEDIFF( dMesSgte, dMes );
	SELECT 'MSG 050 DIAS:', vnTotalDias, nFactorDias, dMesSgte, dMes, dProceso;

	BEGIN
		DECLARE dCount				date;
		DECLARE vpViaje 			integer;
--		DECLARE vnKmsPond			float;
		DECLARE vnKms				float;
		DECLARE vnSumaVelocidad		float;
		DECLARE vnSumaFrenada		float;
		DECLARE vnSumaAceleracion	float;
		DECLARE vnPorcFrenada 		float;
		DECLARE vnPorcAceleracion 	float;
		DECLARE vnPorcVelocidad 	float;
		DECLARE vnPtjVelocidad		float;
		DECLARE vnPtjFrenada		float;
		DECLARE vnPtjAceleracion	float;
		DECLARE vnScore				float;

		DECLARE eofCurViaje integer DEFAULT 0;
		DECLARE curViaje CURSOR FOR
			SELECT vi.nIdViaje
			  FROM vViaje vi;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurViaje = 1;

		SELECT nPorcFrenada / 100 , nPorcAceleracion /100 , nPorcVelocidad /100
		  INTO vnPorcFrenada      , vnPorcAceleracion     , vnPorcVelocidad
		  FROM tParamCalculo;

		SELECT 'MSG 080 Inicio curViaje',now();
		OPEN  curViaje;
		FETCH curViaje INTO vpViaje;
		WHILE NOT eofCurViaje DO
			-- SELECT 'MSG 100', eofCurViaje;

			-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
			SELECT IFNULL(SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN ev.nPuntaje ELSE 0 END ), 0) AS nSumaAceleracion
			     , IFNULL(SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN ev.nPuntaje ELSE 0 END ), 0) AS nSumaFrenada
			     , IFNULL(SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN ev.nPuntaje ELSE 0 END ), 0) AS nSumaVelocidad
				 , IFNULL(SUM( CASE ev.fTpEvento WHEN kEventoFin			THEN ev.nValor   ELSE 0 END ), 0) AS nKms
			  INTO  vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnKms
			  FROM tEvento ev
			 WHERE ev.nIdViaje = vpViaje 
			   AND ev.tEvento >= dMes
			   AND ev.tEvento  < dMesSgte;

			SET vnKms = round( vnKms, 2);
			IF vnKms > 0 THEN
				SET vnPtjVelocidad	 = round( vnSumaVelocidad	* 100 / vnKms, 2);
				SET vnPtjFrenada	 = round( vnSumaFrenada		* 100 / vnKms, 2);
	   			SET vnPtjAceleracion = round( vnSumaAceleracion	* 100 / vnKms, 2);
			ELSE
				SET vnPtjVelocidad	 = 0;
				SET vnPtjFrenada	 = 0;
				SET vnPtjAceleracion = 0;
			END IF;

			-- SELECT 'MSG 120', vnPtjVelocidad, eofCurViaje;
			SELECT nValor INTO vnPtjVelocidad
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoVelocidad
			   AND nInicio <= vnPtjVelocidad and vnPtjVelocidad < nFin;
		    -- SELECT 'MSG 130', vnPtjVelocidad, eofCurViaje;

			-- SELECT 'MSG 140', vnSumaFrenada, vnKms,  vnPtjFrenada;
			SELECT nValor INTO vnPtjFrenada
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoFrenada
			   AND nInicio <= vnPtjFrenada and vnPtjFrenada < nFin;
			-- SELECT 'MSG 150', vnPtjFrenada;

			-- SELECT 'MSG 160', vnPtjAceleracion, eofCurViaje;
			SELECT nValor INTO vnPtjAceleracion
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoAceleracion
			   AND nInicio <= vnPtjAceleracion and vnPtjAceleracion < nFin;
		    -- SELECT 'MSG 170', vnPtjAceleracion, eofCurViaje;

			-- Trae el descuento a aplicar por los puntos
			SET vnScore = ( vnPtjFrenada		* vnPorcFrenada		)
						+ ( vnPtjAceleracion	* vnPorcAceleracion	)
						+ ( vnPtjVelocidad		* vnPorcVelocidad 	);
			SET vnScore = round( vnScore, 2);

			UPDATE tEvento
			   SET nValor = round( vnScore, 2)
			 WHERE tEvento.nIdViaje  = vpViaje
			   AND tEvento.fTpEvento = kEventoInicio;

			-- Siguiente cuenta
			FETCH curViaje INTO vpViaje;
		END WHILE;
		CLOSE curViaje;
		SELECT 'MSG 500', 'Fin curViaje', now();
	END;
END //
DELIMITER ;
call calculaScoreMesViaje(now());

