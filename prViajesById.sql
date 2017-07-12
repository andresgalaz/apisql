DELIMITER //
DROP PROCEDURE IF EXISTS prViajesById //
CREATE PROCEDURE prViajesById ( IN prm_nIdViaje INTEGER )
BEGIN
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;

	-- CURSOR 1: Registro del viaje
	SELECT	ini.fVehiculo			AS	fVehiculo			,	v.cPatente				AS	cPatente
		 ,	ini.nIdViaje			AS	nIdViaje
		 ,	ini.cCalle				AS	cCalleInicio		,	fin.cCalle				AS	cCalleFin
		 ,	ini.cCalleCorta			AS	cCalleCortaInicio	,	fin.cCalleCorta			AS	cCalleCortaFin
		 ,	ini.tEvento				AS	tInicio				,	fin.tEvento				AS	tFin
		 ,	TIMESTAMPDIFF(SECOND, ini.tEvento, fin.tEvento)								AS	nDuracionSeg
		 ,	ROUND(ini.nValor,0)		AS	nScore				,	ROUND(fin.nValor,2)		AS	nKms
		 ,	SUM( IF( eve.fTpEvento = kEventoAceleracion		, 1, 0 )) AS	nQAceleracion
		 ,	SUM( IF( eve.fTpEvento = kEventoFrenada			, 1, 0 )) AS	nQFrenada
		 ,	SUM( IF( eve.fTpEvento = kEventoVelocidad		, 1, 0 )) AS	nQVelocidad
		 ,	SUM( IF( eve.fTpEvento = kEventoCurva			, 1, 0 )) AS	nQCurva
			-- Inicio del Viaje
	FROM	tEvento							AS	ini 
			-- Fin del Viaje
			INNER JOIN tEvento				AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
													AND	fin.fTpEvento	=	kEventoFin
			INNER JOIN tVehiculo			AS 	v	ON	v.pVehiculo		= 	ini.fVehiculo			
			-- Eventos
			LEFT JOIN  tEvento				AS	eve ON	eve.nIdViaje	=	ini.nIdViaje
													AND	eve.fTpEvento not in ( kEventoInicio, kEventoFin )
	WHERE	ini.nIdViaje 	=	prm_nIdViaje
	AND		ini.fTpEvento	=	kEventoInicio
	GROUP BY	ini.fVehiculo	, v.cPatente		, ini.nIdViaje		,
				ini.cCalle		, fin.cCalle		, ini.cCalleCorta	, fin.cCalleCorta	,
				ini.tEvento		, fin.tEvento		, ini.nValor		,
				fin.nValor;
END //
