﻿DELIMITER //
DROP PROCEDURE IF EXISTS prScoreVehiculoRangoFecha //
CREATE PROCEDURE prScoreVehiculoRangoFecha (IN prm_pUsuario INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
BEGIN
	DECLARE kDescLimite			INTEGER	DEFAULT 40;
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;
	
	DECLARE vdIni				DATE;
	DECLARE vdFin				DATE;
	DECLARE vnKmsTotal			DECIMAL(10,2)	DEFAULT 0.0;
	DECLARE vnScoreGlobal		DECIMAL(10,2)	DEFAULT 0.0;
	
	IF prm_dIni IS NULL THEN
		SET vdIni = DATE(DATE_SUB(now(), INTERVAL DAYOFMONTH(now()) - 1 DAY));
	ELSE
		SET vdIni = prm_dIni;
	END IF;

	IF prm_dFin IS NULL THEN
		SET vdFin = now();
	ELSE
		SET vdFin = prm_dFin;
	END IF;

--	IF vdIni > vdFin THEN
--		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio no puede ser inferior a la fecha de fin';
--	END IF;
	SET vdFin = ADDDATE(vdFin, INTERVAL 1 DAY);

	-- Crea tabla temporal, si existe la limpia
	CALL prCreaTmpScoreVehiculo();

	BEGIN
		DECLARE vpVehiculo				INTEGER;
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
		-- Sale de la tabla tParamCalculo: Distancia minima en KMS
		DECLARE vnDistanciaMin			DECIMAL(10,2) DEFAULT 0;
		
		-- Cursor Vehiculos para borrar 
		DECLARE eofCurVeh INTEGER DEFAULT 0;
		DECLARE CurVeh CURSOR FOR
			SELECT uv.pVehiculo, uv.fUsuarioTitular
				 	-- Calcula Score del usuario
				 ,	SUM( t.nKms				)	nKmsUsr				 ,	SUM( t.nFrenada			)	nSumaFrenadaUsr
				 ,	SUM( t.nAceleracion		)	nSumaAceleracionUsr	 ,	SUM( t.nVelocidad		)	nSumaVelocidadUsr
				 ,	SUM( t.nCurva			)	nSumaCurvaUsr		 ,	SUM( t.nQFrenada		)	nQFrenadaUsr
				 ,	SUM( t.nQAceleracion	)	nQAceleracionUsr	 ,	SUM( t.nQVelocidad		)	nQVelocidadUsr
				 ,	SUM( t.nQCurva			)	nQCurvaUsr
			FROM	tUsuarioVehiculo uv
					JOIN tScoreDia t ON t.fVehiculo =	uv.pVehiculo
									AND t.fUsuario	=	uv.pUsuario
			WHERE	t.dFecha	>=	vdIni
			AND		t.dFecha	<	vdFin
			AND		uv.pUsuario =	prm_pUsuario
			GROUP BY uv.pVehiculo, uv.fUsuarioTitular;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;

		OPEN CurVeh;
		FETCH CurVeh INTO vpVehiculo		, vfUsuarioTitular		, vnKmsUsr
						, vnSumaFrenadaUsr	, vnSumaAceleracionUsr	, vnSumaVelocidadUsr, vnSumaCurvaUsr
						, vnQFrenadaUsr		, vnQAceleracionUsr		, vnQVelocidadUsr	, vnQCurvaUsr;
		WHILE NOT eofCurVeh DO
			CALL prCalculaScoreVehiculo( vpVehiculo, vdIni, vdFin );
		
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
				SET vnKmsTotal		= vnKmsTotal	+ vnKmsUsr;
				SET vnScoreGlobal	= vnScoreGlobal	+ vnScoreUsr * vnKmsUsr;
			
				SELECT	COUNT(*) INTO vnQViajesUsr
				FROM	tEvento e
						INNER JOIN tParamCalculo p ON 1 = 1
				WHERE	e.fUsuario	= 	prm_pUsuario
				AND		e.fVehiculo =	vpVehiculo
				AND		e.tEvento	>=	vdIni
				AND		e.tEvento	<	vdFin
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
				WHERE	pVehiculo	= vpVehiculo;
			ELSE
				-- Acumula los totales del vehículo
				SELECT	nKms + vnKmsTotal	, nScore * nKms + vnScoreGlobal
				INTO	vnKmsTotal			, vnScoreGlobal
				FROM	wMemoryScoreVehiculo
				WHERE	pVehiculo = vpVehiculo;
			END IF;

			FETCH CurVeh INTO vpVehiculo		, vfUsuarioTitular
							, vnKmsUsr
							, vnSumaFrenadaUsr	, vnSumaAceleracionUsr	, vnSumaVelocidadUsr, vnSumaCurvaUsr
							, vnQFrenadaUsr		, vnQAceleracionUsr		, vnQVelocidadUsr	, vnQCurvaUsr;
		END WHILE;
		CLOSE CurVeh;
	END;

	-- CURSOR 1: Entrega un cursor con los totales globales del Usuario
	IF vnKmsTotal <= 0 THEN
		SELECT 0 AS kmsTotal, 100 AS scoreGlobal; 
	ELSE
		SELECT vnKmsTotal AS nKmsTotal, round( vnScoreGlobal	/ vnKmsTotal, 0 ) AS nScoreGlobal; 
	END IF;
	-- CURSOR 2: Entrega un cursor con el detalle por vehículo
	SELECT w.pVehiculo			, v.cPatente
		 , v.fUsuarioTitular	, ut.cNombre			AS cUsuarioTitular
		 , w.nKms				, w.nScore
		 , w.nDescuento			, w.nDiasTotal
		 , w.nDiasUso			, w.nDiasPunta
		 , w.nQFrenada			, w.nQAceleracion		, w.nQVelocidad			, w.nQCurva
		 , w.nQViajes
	FROM wMemoryScoreVehiculo w
		 JOIN score.tVehiculo	v	ON v.pVehiculo = w.pVehiculo
		 JOIN score.tUsuario	ut	ON ut.pUsuario = v.fUsuarioTitular;
	-- CURSOR 3: Entrega un cursor con los conductores que pueden usar los vehiculos 
	-- 			 que este usuario puede usar
	SELECT	uv2.pVehiculo, uv2.pUsuario, u.cNombre cUsuario
		 ,	SUM( t.nKms )	nKms
	FROM	tUsuarioVehiculo uv1 
			INNER JOIN tUsuarioVehiculo uv2	ON uv2.pVehiculo	= uv1.pVehiculo
			INNER JOIN tUsuario			u	ON u.pUsuario		= uv2.pUsuario
			INNER JOIN tScoreDia		t	ON t.fUsuario		= uv2.pUsuario
	WHERE	t.dFecha	>=	vdIni
	AND		t.dFecha	<	vdFin
	AND		uv1.pUsuario =	prm_pUsuario
	GROUP BY uv2.pVehiculo, uv2.pUsuario, u.cNombre;
	-- CURSOR 4: Resumen final, cuenta todos los eventos de usuario
	SELECT	SUM( t.nQFrenada		)	nQFrenada
		 ,	SUM( t.nQAceleracion	)	nQAceleracion
		 ,	SUM( t.nQVelocidad		)	nQVelocidad
		 ,	SUM( t.nQCurva			)	nQCurva
	FROM	tScoreDia	t
	WHERE	t.dFecha	>=	vdIni
	AND		t.dFecha	<	vdFin
	AND		t.fUsuario =	prm_pUsuario;
	-- CURSOR 5: Detalle de los viajes del usuario
	SELECT	v.pVehiculo				AS	fVehiculo		,	v.cPatente				AS	cPatente
		 ,	v.fUsuarioTitular		AS	fUsuarioTitular ,	ut.cNombre				AS	cNombreTitular
		 ,	ini.fUsuario			AS	fUsuario	 	,	IFNULL(uu.cNombre,'Desconocido') AS cNombreConductor
		 ,	ini.nIdViaje			AS	nIdViaje
		 ,	ini.cCalle				AS	cCalleInicio	,	fin.cCalle				AS	cCalleFin
		 ,	ini.tEvento				AS	tInicio			,	fin.tEvento				AS	tFin
		 ,	TIMESTAMPDIFF(SECOND, ini.tEvento, fin.tEvento)							AS	nDuracionSeg
		 ,	ROUND(ini.nValor,0)	AS	nScore			,	ROUND(fin.nValor,2)	AS	nKms
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoAceleracion	THEN 1 ELSE 0 END ) AS	nQAceleracion
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoFrenada		THEN 1 ELSE 0 END ) AS	nQFrenada
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoVelocidad		THEN 1 ELSE 0 END ) AS	nQVelocidad
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoCurva			THEN 1 ELSE 0 END ) AS	nQCurva
	FROM	tParamCalculo				AS	prm
			-- Inicio del Viaje
			INNER JOIN tEvento			AS	ini ON	ini.fTpEvento	=	kEventoInicio
			-- Fin del Viaje
			INNER JOIN tEvento			AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
										       AND	fin.fTpEvento   =	kEventoFin
											   AND	fin.nValor		> 	prm.nDistanciaMin
			-- Eventos
			INNER JOIN tEvento			AS	eve ON	eve.nIdViaje	=	ini.nIdViaje
												AND	eve.fTpEvento not in ( kEventoInicio, kEventoFin )
			INNER JOIN tVehiculo		AS 	v	ON	v.pVehiculo		= 	ini.fVehiculo
			-- Solo muestra los viajes de los usuario relacionados. Pueden existir viajes de usuario no identificados
			INNER JOIN tUsuarioVehiculo AS	uv	ON	uv.pVehiculo	= 	ini.fVehiculo
											   AND	uv.pUsuario		=	ini.fUsuario
			INNER JOIN tUsuario			AS	ut	ON	ut.pUsuario		=	v.fUsuarioTitular
			LEFT JOIN  tUsuario			AS	uu	ON	uu.pUsuario		=	ini.fUsuario
	WHERE	ini.fUsuario	=	prm_pUsuario
	AND		ini.tEvento		>=	vdIni
	AND		fin.tEvento		<	vdFin
	GROUP BY	v.pVehiculo	,	v.cPatente	,	v.fUsuarioTitular	,	ut.cNombre
		 	,	ini.fUsuario,	uu.cNombre	,	ini.nIdViaje		,	ini.cCalle
			,	fin.cCalle 	,	ini.tEvento	,	fin.tEvento			,	ini.nValor
			,	fin.nValor	
	ORDER BY ini.tEvento DESC;

END //