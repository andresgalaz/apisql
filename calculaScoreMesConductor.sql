DROP PROCEDURE IF EXISTS calculaScoreMesConductor;
DELIMITER //
CREATE PROCEDURE calculaScoreMesConductor (in prmMes date)
BEGIN
	DECLARE kDescDiaSinUso		float   DEFAULT 1;
	DECLARE kDescNoUsoPunta		float	DEFAULT 0.5;

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
		DECLARE vpScoreMesConductor	integer;
		DECLARE vpVehiculo			integer;
		DECLARE vpUsuario			integer;
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
		DECLARE vnDescDiaSinUso		float;
		DECLARE vnDescNoHoraPunta	float;
		DECLARE vnDiasUso			integer;
		DECLARE vnDiasPunta			integer;
		DECLARE vnScore				float;
--		DECLARE vnDescuentoKM		float;
--		DECLARE vnDescuentoPtje		float;
--		DECLARE vnDescuento			float;
		DECLARE cStmt				varchar(500);

		DECLARE eofCurConductor integer DEFAULT 0;
		DECLARE curConductor CURSOR FOR
			SELECT uv.pUsuario, uv.pVehiculo
			  FROM tUsuarioVehiculo uv;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurConductor = 1;

		SELECT nPorcFrenada / 100 , nPorcAceleracion /100 , nPorcVelocidad /100
			 , nDescDiaSinUso     , nDescNoHoraPunta
		  INTO vnPorcFrenada      , vnPorcAceleracion     , vnPorcVelocidad
			 , vnDescDiaSinUso    , vnDescNoHoraPunta
		  FROM tParamCalculo;

		SELECT 'MSG 060 Limpia tScoreMesConductor:', dMes;
        DELETE FROM tScoreMesConductor WHERE dPeriodo >= dMes AND dPeriodo < dMesSgte;
		SELECT 'MSG 062 MAX pScoreMesConductor';
        SELECT IFNULL(MAX(pScoreMesConductor),0)+1
		  INTO vpScoreMesConductor
		  FROM tScoreMesConductor;
		SELECT 'MSG 070 Reinicia pScoreMesConductor', vpScoreMesConductor;
		SET @SQL := CONCAT( 'ALTER TABLE tScoreMesConductor AUTO_INCREMENT=', vpScoreMesConductor );
		PREPARE cStmt FROM @SQL;
		EXECUTE cStmt;
		DEALLOCATE PREPARE cStmt;

		SELECT 'MSG 080 Inicio curConductor',now();
		OPEN  curConductor;
		FETCH curConductor INTO vpUsuario, vpVehiculo;
		WHILE NOT eofCurConductor DO
			-- SELECT 'MSG 100', vpVehiculo, eofCurConductor;

			-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
			SELECT SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN ev.nPuntaje ELSE 0 END ) AS nSumaAceleracion
			     , SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN ev.nPuntaje ELSE 0 END ) AS nSumaFrenada
			     , SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN ev.nPuntaje ELSE 0 END ) AS nSumaVelocidad
				 , SUM( CASE ev.fTpEvento WHEN kEventoFin			THEN ev.nValor   ELSE 0 END ) AS nKms
				 , COUNT( DISTINCT DATE( tEvento )) AS nDiasUso
			  INTO  vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnKms, vnDiasUso
			  FROM tEvento ev
			 WHERE ev.fUsuario  = vpUsuario
			   AND ev.fVehiculo = vpVehiculo
			   AND ev.tEvento  >= dMes
			   AND ev.tEvento   < dMesSgte;

			-- Cuenta días hora punta, el DISTINCT es para contar el día una sola vez, no importa la
			-- cantidad de viaje en el mismo día
			SELECT COUNT( DISTINCT DATE( tEvento )) AS nDiasPunta
			  INTO vnDiasPunta
			  FROM tEvento ev
			 WHERE ev.fUsuario  = vpUsuario
			   AND ev.fVehiculo = vpVehiculo
			   AND ev.tEvento  >= dMes
			   AND ev.tEvento  <  dMesSgte
			   AND esHoraPunta( ev.tEvento ) = 1;

			SET vnDiasPunta = IFNULL( vnDiasPunta, 0);
			SET vnDiasUso   = IFNULL( vnDiasUso  , 0);
			IF vnDiasUso = 0 THEN
				SET vnDiasUso           = 0;
				SET vnKms               = 0;
				SET vnSumaVelocidad     = 0;
				SET vnSumaFrenada       = 0;
				SET vnSumaAceleracion   = 0;
				SET vnPtjVelocidad      = 0;
				SET vnPtjFrenada        = 0;
				SET vnPtjAceleracion    = 0;
				SET vnPtjAceleracion    = 0;
			ELSE
				SET vnKms = round( IFNULL( vnKms, 0), 2);
				IF vnKms > 0 THEN
					SET vnPtjVelocidad	 = round( IFNULL( vnSumaVelocidad  , 0)* 100 / vnKms, 2);
					SET vnPtjFrenada	 = round( IFNULL( vnSumaFrenada    , 0)* 100 / vnKms, 2);
	   				SET vnPtjAceleracion = round( IFNULL( vnSumaAceleracion, 0)* 100 / vnKms, 2);
				ELSE
					SET vnPtjVelocidad	 = 0;
					SET vnPtjFrenada	 = 0;
					SET vnPtjAceleracion = 0;
				END IF;
			END IF;

			-- SELECT 'MSG 120', vpVehiculo,  vnPtjVelocidad, eofCurConductor;
			SELECT nValor INTO vnPtjVelocidad
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoVelocidad
			   AND nInicio <= vnPtjVelocidad and vnPtjVelocidad < nFin;
		    -- SELECT 'MSG 130', vpVehiculo,  vnPtjVelocidad, eofCurConductor;

			-- SELECT 'MSG 140', vpVehiculo, vnSumaFrenada, vnKms,  vnPtjFrenada, vnDiasUso;
			SELECT nValor INTO vnPtjFrenada
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoFrenada
			   AND nInicio <= vnPtjFrenada and vnPtjFrenada < nFin;
			-- SELECT 'MSG 150', vpVehiculo, vnPtjFrenada;

			-- SELECT 'MSG 160', vpVehiculo,  vnPtjAceleracion, eofCurConductor;
			SELECT nValor INTO vnPtjAceleracion
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoAceleracion
			   AND nInicio <= vnPtjAceleracion and vnPtjAceleracion < nFin;
		    -- SELECT 'MSG 170', vpVehiculo,  vnPtjAceleracion, eofCurConductor;

			-- Trae el descuento por kilómetros recorridos en el mes (o mes ponderado)
			-- si vnDescuento resulta negativo, en realidad es un recargo
--			SET vnKmsPond = round(vnKms / nFactorDias, 2);
--			SELECT d.nValor
--			  INTO vnDescuentoKM
--			  FROM tRangoDescuento d
--			 WHERE d.cTpDescuento = 'KM'
--			   AND d.nInicio <= vnKmsPond AND vnKmsPond < nFin;

			-- Trae el descuento a aplicar por los puntos
			IF( vnKms > 0 ) THEN
				SET vnScore = ( vnPtjFrenada * vnPorcFrenada )
							+ ( vnPtjAceleracion * vnPorcAceleracion )
							+ ( vnPtjVelocidad * vnPorcVelocidad );
				SET vnScore = round( vnScore, 2);
			ELSE
				SET vnScore = 100;
				SET vnKms	= 0;
			END IF;
--			SELECT d.nValor
--			  INTO vnDescuentoPtje
--			  FROM tRangoDescuento d
--			 WHERE d.cTpDescuento = 'SCORE'
--			   AND d.nInicio <= vnScore AND vnScore < nFin;

			-- SELECT 'MSG 172', vnPtjVelocidad, vnPtjFrenada, vnPtjAceleracion, vnDescuentoKM, vnScore, vnDescuentoPtje;
--			SET vnDescuento = vnDescuentoKM;
			-- Descuento por días sin uso
--			SET vnDescuento = vnDescuento + ( vnTotalDias - vnDiasUso ) * kDescDiaSinUso;
			-- Descuento por días de uso fuera de hora Punta, es igual a los días usados - los días en Punta
--			SET vnDescuento = vnDescuento + ( vnDiasUso - vnDiasPunta ) * kDescNoUsoPunta;
			-- Ajusta por el Puntaje
--			SET vnDescuento = vnDescuento * vnDescuentoPtje;
			INSERT INTO tScoreMesConductor
				   ( fVehiculo      	, fUsuario
				   , dPeriodo			, nScore				, nKms
				   , nSumaFrenada  	 	, nSumaAceleracion		, nSumaVelocidad
				   , nFrenada	   	 	, nAceleracion			, nVelocidad
				   , nTotalDias			, nDiasUso				, nDiasPunta	)
			VALUES ( vpVehiculo     	, vpUsuario
				   , dMes				, round( vnScore, 2) 	, round(vnKms,2)
				   , vnSumaFrenada  	, vnSumaAceleracion		, vnSumaVelocidad
				   , vnPtjFrenada   	, vnPtjAceleracion		, vnPtjVelocidad
				   , vnTotalDias		, vnDiasUso				, vnDiasPunta	);
			SET vpScoreMesConductor = LAST_INSERT_ID();

			-- Siguiente cuenta
			FETCH curConductor INTO vpUsuario, vpVehiculo;
		END WHILE;
		CLOSE curConductor;
		SELECT 'MSG 500', 'Fin curConductor', now(), vpScoreMesConductor;
	END;
END //
DELIMITER ;
-- call calculaScoreMesConductor(now());
