DELIMITER //
USE score //
DROP FUNCTION IF EXISTS fnScoreConductorJson //
CREATE FUNCTION fnScoreConductorJson( prm_pUsuario INTEGER, prm_pVehiculo INTEGER,  prm_dIni DATE, prm_dFin DATE ) RETURNS VARCHAR(100)
BEGIN
	/*
    Función usada para obtener la suma de KMS y Score, como STRING con formato JSON.
    */
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;

	DECLARE vnKms				DECIMAL(10,2);
	DECLARE vnPtjFrenada		DECIMAL(10,2);
	DECLARE vnPtjAceleracion	DECIMAL(10,2);
	DECLARE vnPtjVelocidad		DECIMAL(10,2);
	DECLARE vnPtjCurva			DECIMAL(10,2);
	DECLARE vnScore				DECIMAL(10,2);

	SELECT	SUM( IF( eve.fTpEvento = kEventoAceleracion	, eve.nPuntaje	, 0 ))	AS nSumaAceleracion	,
			SUM( IF( eve.fTpEvento = kEventoVelocidad	, eve.nPuntaje	, 0 ))	AS nSumaVelocidad	,
			SUM( IF( eve.fTpEvento = kEventoFrenada		, eve.nPuntaje	, 0 ))	AS nSumaFrenada		,
			SUM( IF( eve.fTpEvento = kEventoCurva		, eve.nPuntaje	, 0 ))	AS nSumaCurva		,
			SUM( IF( eve.fTpEvento = kEventoFin			, eve.nValor	, 0 ))	AS nKms
	INTO    vnPtjAceleracion, vnPtjVelocidad, vnPtjFrenada, vnPtjCurva, vnKms
	FROM	tEvento 		AS	ini
			JOIN tEvento	AS	fin ON	fin.nIdViaje	=	ini.nIdViaje
									AND	fin.fTpEvento	=	kEventoFin
			JOIN tEvento	AS	eve	ON	eve.nIdViaje	=	ini.nIdViaje
	WHERE	ini.ftpEvento	=	kEventoInicio
	AND		ini.fUsuario	=	prm_pUsuario
	AND		ini.fVehiculo	=	prm_pVehiculo
	AND		ini.tEvento		>=	prm_dIni
	AND		ini.tEvento		<	prm_dFin;

	IF IFNULL(vnKms, 0) > 0 THEN
		SET vnPtjFrenada		= vnPtjFrenada		* 100 / vnKms;
		SET vnPtjAceleracion	= vnPtjAceleracion	* 100 / vnKms;
		SET vnPtjVelocidad		= vnPtjVelocidad	* 100 / vnKms;
		SET vnPtjCurva			= vnPtjCurva		* 100 / vnKms;
			
		SELECT	nValor INTO vnPtjFrenada
		FROM	tRangoPuntaje WHERE fTpevento = kEventoFrenada AND nInicio <= vnPtjFrenada and vnPtjFrenada < nFin;

		SELECT	nValor INTO vnPtjAceleracion
		FROM	tRangoPuntaje WHERE fTpevento = kEventoAceleracion AND nInicio <= vnPtjAceleracion and vnPtjAceleracion < nFin;

		SELECT nValor INTO vnPtjVelocidad
		FROM   tRangoPuntaje WHERE fTpevento = kEventoVelocidad AND nInicio <= vnPtjVelocidad and vnPtjVelocidad < nFin;

		SELECT nValor INTO vnPtjCurva
		FROM   tRangoPuntaje WHERE fTpevento = kEventoCurva AND nInicio <= vnPtjCurva and vnPtjCurva < nFin;

		-- Parámetros de ponderación por tipo de evento
		SELECT	( vnPtjFrenada		* nPorcFrenada		/ 100 )
			+	( vnPtjAceleracion	* nPorcAceleracion	/ 100 )
			+	( vnPtjVelocidad	* nPorcVelocidad	/ 100 )
			+	( vnPtjCurva		* nPorcCurva		/ 100 )
		INTO	vnScore
		FROM	tParamCalculo;
	ELSE
		SET vnKms  			= 0;
		SET vnScore 		= 100;
	END IF;

	RETURN CONCAT('{ "nKms":', ROUND(vnKms,2), ', "nScore":', ROUND(vnScore,0), '}');
END //
