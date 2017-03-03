DROP PROCEDURE IF EXISTS score_desa.calculaScoreMesConductorVeh;
CREATE PROCEDURE score_desa.`calculaScoreMesConductorVeh`(in prmMes date)
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

	
	SET dMes	 = DATE(DATE_SUB(prmMes, INTERVAL DAYOFMONTH(prmMes) - 1 DAY));
	SET dMesSgte = ADDDATE(dMes, INTERVAL 1 MONTH);
	SET dProceso = DATE(NOW());

	IF dMesSgte > dProceso THEN
		
		SET vnTotalDias = DATEDIFF( dProceso, dMes ) + 1;
	ELSE
		
		SET vnTotalDias = DATEDIFF( dMesSgte, dMes );
	END IF;
	SET nFactorDias = vnTotalDias / DATEDIFF( dMesSgte, dMes );
	SELECT 'MSG 050 DIAS:', vnTotalDias, nFactorDias, dMesSgte, dMes, dProceso;

	BEGIN
		DECLARE dCount				date;
		DECLARE vpScoreMesConductor	integer;
		DECLARE vpVehiculo			integer;
		DECLARE vpUsuario			integer;

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

		SELECT 'MSG 060 Limpia tScoreMesConductorVeh:', dMes;
        DELETE FROM tScoreMesConductor WHERE dPeriodo >= dMes AND dPeriodo < dMesSgte;
		SELECT 'MSG 062 MAX pScoreMesConductor';
        SELECT IFNULL(MAX(pScoreMesConductor),0)+1
		  INTO vpScoreMesConductor
		  FROM tScoreMesConductorVeh;
		SELECT 'MSG 070 Reinicia pScoreMesConductor', vpScoreMesConductor;
		SET @SQL := CONCAT( 'ALTER TABLE tScoreMesConductorVeh AUTO_INCREMENT=', vpScoreMesConductor );
		PREPARE cStmt FROM @SQL;
		EXECUTE cStmt;
		DEALLOCATE PREPARE cStmt;

		SELECT 'MSG 080 Inicio curConductor',now();
		OPEN  curConductor;
		FETCH curConductor INTO vpUsuario, vpVehiculo;
		WHILE NOT eofCurConductor DO
			

			
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

			
			SELECT nValor INTO vnPtjVelocidad
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoVelocidad
			   AND nInicio <= vnPtjVelocidad and vnPtjVelocidad < nFin;
		    

			
			SELECT nValor INTO vnPtjFrenada
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoFrenada
			   AND nInicio <= vnPtjFrenada and vnPtjFrenada < nFin;
			

			
			SELECT nValor INTO vnPtjAceleracion
			  FROM tRangoPuntaje
			 WHERE fTpevento = kEventoAceleracion
			   AND nInicio <= vnPtjAceleracion and vnPtjAceleracion < nFin;
		    

			
			







			
			SET vnScore = ( vnPtjFrenada * vnPorcFrenada )
						+ ( vnPtjAceleracion * vnPorcAceleracion )
						+ ( vnPtjVelocidad * vnPorcVelocidad );
			SET vnScore = round( vnScore, 2);






			

			

			

			

			INSERT INTO tScoreMesConductorVeh
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

			
			FETCH curConductor INTO vpUsuario, vpVehiculo;
		END WHILE;
		CLOSE curConductor;
		SELECT 'MSG 500', 'Fin curConductor', now(), vpScoreMesConductor;
	END;
END;
