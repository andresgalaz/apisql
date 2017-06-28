DELIMITER //
DROP PROCEDURE IF EXISTS prScoreVehiculoRangoSub //
CREATE PROCEDURE prScoreVehiculoRangoSub( IN prm_pUsuario INTEGER, IN prm_pVehiculo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE,
										 OUT prm_nKmsTotal DECIMAL(10,2), OUT prm_nScoreGlobal DECIMAL(10,2))
BEGIN
	/*
	Este procedimiento es solo un Sub-Cursor del procedimiento principal:
		prScoreVehiculoRangoFecha
	Tiene 2 tipos de salidas:
		Explicitas por los parámetros OUT
		Implicitas por los registros insertados en la tabla temporal wMemoryScoreVehiculo
	*/
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;
	
	SET prm_nKmsTotal = 0;
	SET prm_nScoreGlobal	= 0;

	BEGIN
		DECLARE vfUsuarioTitular		INTEGER;
		-- Calculo Score usuario
		DECLARE vnQViajesUsr			INTEGER;
		DECLARE vnScoreUsr				DECIMAL(10,2);
		DECLARE vnKmsUsr				DECIMAL(10,2);
		DECLARE vnSumaFrenadaUsr		DECIMAL(10,2);
		DECLARE vnSumaAceleracionUsr	DECIMAL(10,2);
		DECLARE vnSumaVelocidadUsr		DECIMAL(10,2);
		DECLARE vnSumaCurvaUsr			DECIMAL(10,2);
		DECLARE vnQFrenadaUsr			INTEGER;
		DECLARE vnQAceleracionUsr		INTEGER;
		DECLARE vnQVelocidadUsr			INTEGER;
		DECLARE vnQCurvaUsr				INTEGER;
		DECLARE vnPtjFrenadaUsr			DECIMAL(10,2) DEFAULT 0;
		DECLARE vnPtjAceleracionUsr		DECIMAL(10,2) DEFAULT 0;
		DECLARE vnPtjVelocidadUsr		DECIMAL(10,2) DEFAULT 0;
		DECLARE vnPtjCurvaUsr			DECIMAL(10,2) DEFAULT 0;
		
		-- Cursor Vehiculos para borrar 
		DECLARE eofCur INTEGER DEFAULT 0;
		DECLARE Cur CURSOR FOR
			SELECT uv.fUsuarioTitular
				 	-- Calcula Score del usuario
				 ,	SUM( t.nKms				)	nKmsUsr				 ,	SUM( t.nFrenada			)	nSumaFrenadaUsr
				 ,	SUM( t.nAceleracion		)	nSumaAceleracionUsr	 ,	SUM( t.nVelocidad		)	nSumaVelocidadUsr
				 ,	SUM( t.nCurva			)	nSumaCurvaUsr		 ,	SUM( t.nQFrenada		)	nQFrenadaUsr
				 ,	SUM( t.nQAceleracion	)	nQAceleracionUsr	 ,	SUM( t.nQVelocidad		)	nQVelocidadUsr
				 ,	SUM( t.nQCurva			)	nQCurvaUsr
			FROM	tUsuarioVehiculo uv
					JOIN tScoreDia t ON t.fVehiculo =	uv.pVehiculo
									AND t.fUsuario	=	uv.pUsuario
			WHERE	t.dFecha		>=	prm_dIni
			AND		t.dFecha		<	prm_dFin
			AND		uv.pUsuario		=	prm_pUsuario
			AND		uv.pVehiculo	=	prm_pVehiculo 
			GROUP BY uv.pVehiculo, uv.fUsuarioTitular;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;

		OPEN Cur;
		FETCH Cur INTO	vfUsuarioTitular	, vnKmsUsr				,
						vnSumaFrenadaUsr	, vnSumaAceleracionUsr	, vnSumaVelocidadUsr, vnSumaCurvaUsr,
						vnQFrenadaUsr		, vnQAceleracionUsr		, vnQVelocidadUsr	, vnQCurvaUsr	;
		WHILE NOT eofCur DO
			IF IFNULL(vnKmsUsr,0) = 0 THEN
				SET vnKmsUsr			= 0;
				SET vnSumaFrenadaUsr	= 0;
				SET vnSumaAceleracionUsr= 0;
				SET vnSumaVelocidadUsr	= 0;
				SET vnSumaCurvaUsr		= 0;
				SET vnQFrenadaUsr		= 0;
				SET vnQAceleracionUsr	= 0;
				SET vnQVelocidadUsr		= 0;
				SET vnQCurvaUsr			= 0;
			ELSE
				IF vnKmsUsr > 0 then
					SET vnPtjFrenadaUsr		= vnSumaFrenadaUsr		* 100 / vnKmsUsr;
					SET vnPtjAceleracionUsr	= vnSumaAceleracionUsr	* 100 / vnKmsUsr;
					SET vnPtjVelocidadUsr	= vnSumaVelocidadUsr	* 100 / vnKmsUsr;
					SET vnPtjCurvaUsr		= vnSumaCurvaUsr		* 100 / vnKmsUsr;
				END IF;
			END IF;

			-- Calcula Score Usuario
			-- De acuerdo al tipo de evento, se hace la conversión usando la tablas de rangos por puntaje
			SELECT	nValor INTO vnPtjFrenadaUsr FROM tRangoPuntaje
			WHERE	fTpevento = kEventoFrenada AND nInicio <= vnPtjFrenadaUsr AND vnPtjFrenadaUsr < nFin;

			SELECT	nValor INTO vnPtjAceleracionUsr FROM tRangoPuntaje
			WHERE	fTpevento = kEventoAceleracion AND nInicio <= vnPtjAceleracionUsr AND vnPtjAceleracionUsr < nFin;

			SELECT	nValor INTO vnPtjVelocidadUsr FROM tRangoPuntaje
			WHERE	fTpevento = kEventoVelocidad AND nInicio <= vnPtjVelocidadUsr AND vnPtjVelocidadUsr < nFin;

			SELECT	nValor INTO vnPtjCurvaUsr FROM tRangoPuntaje
			WHERE	fTpevento = kEventoCurva AND nInicio <= vnPtjCurvaUsr AND vnPtjCurvaUsr < nFin;

			-- Parámetros de ponderación por tipo de evento
			SELECT	( vnPtjFrenadaUsr		* nPorcFrenada		/ 100 )
				+	( vnPtjAceleracionUsr	* nPorcAceleracion	/ 100 )
				+	( vnPtjVelocidadUsr		* nPorcVelocidad	/ 100 )
				+	( vnPtjCurvaUsr			* nPorcCurva		/ 100 )
			INTO	vnScoreUsr
			FROM	tParamCalculo;

			-- Si no es el titular, se muestran los KM y Viajes del usuario solamente, no los del vehículo
			-- por eso se actualiza la tabla temporal que generó prCalculaScoreVehiculo
			IF prm_pUsuario <> vfUsuarioTitular THEN
				-- Kimoletros totales del usuario y Score Global por Kilometro
				SET prm_nKmsTotal		= prm_nKmsTotal	+ vnKmsUsr;
				SET prm_nScoreGlobal	= prm_nScoreGlobal	+ vnScoreUsr * vnKmsUsr;
			
				SELECT	COUNT(*) INTO vnQViajesUsr
				FROM	tEvento e
						INNER JOIN tParamCalculo p ON 1 = 1
				WHERE	e.fUsuario	= 	prm_pUsuario
				AND		e.fVehiculo =	prm_pVehiculo
				AND		e.tEvento	>=	prm_dIni
				AND		e.tEvento	<	prm_dFin
				AND		e.fTpEvento =	kEventoFin
				AND		e.nValor	>	p.nDistanciaMin;

				UPDATE	wMemoryScoreVehiculo
				SET		nKms			= vnKmsUsr
					,	nQViajes		= vnQViajesUsr
					,	nScore			= vnScoreUsr
					,	nQFrenada		= vnQFrenadaUsr
					,	nQAceleracion	= vnQAceleracionUsr
					,	nQVelocidad		= vnQVelocidadUsr
					,	nQCurva			= vnQCurvaUsr
				WHERE	pVehiculo	= prm_pVehiculo;
			ELSE
				-- Acumula los totales del vehículo
				SELECT	nKms + prm_nKmsTotal	, nScore * nKms + prm_nScoreGlobal
				INTO	prm_nKmsTotal			, prm_nScoreGlobal
				FROM	wMemoryScoreVehiculo
				WHERE	pVehiculo = prm_pVehiculo;
			END IF;

			FETCH Cur INTO	vfUsuarioTitular	, vnKmsUsr				,
							vnSumaFrenadaUsr	, vnSumaAceleracionUsr	, vnSumaVelocidadUsr, vnSumaCurvaUsr,
							vnQFrenadaUsr		, vnQAceleracionUsr		, vnQVelocidadUsr	, vnQCurvaUsr	;
		END WHILE;
		CLOSE Cur;
	END;
END //
