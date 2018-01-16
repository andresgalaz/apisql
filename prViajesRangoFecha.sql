DELIMITER //
DROP PROCEDURE IF EXISTS prViajesRangoFecha //
CREATE PROCEDURE prViajesRangoFecha ( IN prm_pUsuario INTEGER, IN prm_nPagina INTEGER, IN prm_nPeriodo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
BEGIN
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;
	DECLARE kPageSize			INTEGER DEFAULT 30;

	DECLARE vdIni			DATE;
	DECLARE vdFin			DATE;
    DECLARE vnRegs			INTEGER;
    DECLARE vnRegIni		INTEGER;
    DECLARE	vnPagina		INTEGER;
    DECLARE	vnPaginas		INTEGER;

	IF prm_nPeriodo IS NOT NULL THEN
		-- Primer día mes actual
		SET vdIni = DATE(DATE_SUB(fnNowTest(), INTERVAL DAY(fnNowTest()) - 1 DAY));
		SET vdIni = fnFechaCierreIni( vdIni, prm_nPeriodo );
		SET vdFin = fnFechaCierreFin( vdIni, prm_nPeriodo );
	ELSEIF prm_dIni IS NOT NULL AND prm_dFin IS NOT NULL THEN
		IF prm_dIni IS NULL THEN
			SET vdIni = DATE(DATE_SUB(fnNowTest(), INTERVAL DAYOFMONTH(fnNowTest()) - 1 DAY));
		ELSE
			SET vdIni = prm_dIni;
		END IF;

		IF prm_dFin IS NULL THEN
			SET vdFin = fnNowTest();
		ELSE
			SET vdFin = prm_dFin;
		END IF;
		SET vdFin = ADDDATE(vdFin, INTERVAL 1 DAY);
	ELSE
		SET vdIni = DATE('2000-01-01');
        SET vdFin = DATE('2999-12-31');
	END IF;

	-- Cuenta cantidad de registros para poder paginar
	SELECT	COUNT(*)			AS nRegs
    INTO	vnRegs
	FROM	tUsuarioVehiculo		AS	uv
			INNER JOIN	tVehiculo	AS 	v	ON	v.pVehiculo		= 	uv.pVehiculo
			-- Inicio del Viaje
			INNER JOIN tEvento		AS	ini ON	ini.fVehiculo	= 	uv.pVehiculo
											AND	ini.fTpEvento	=	kEventoInicio
			-- Fin del Viaje
			INNER JOIN tEvento		AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
											AND	fin.fTpEvento	=	kEventoFin
	WHERE	uv.pUsuario		=	prm_pUsuario
	AND		ini.tEvento		>=	vdIni
	AND		fin.tEvento		<	vdFin;
    
    SET vnRegs		= ifnull(vnRegs, 0 );
    SET vnPaginas	= ceil( vnRegs / kPageSize );
    SET vnPagina	= ifnull(prm_nPagina,least(0,vnPaginas));
    IF vnPagina <= 0 THEN
		SET vnPagina = 1;
	ELSEIF vnPagina > vnPaginas THEN
		SET vnPagina = vnPaginas;
	END IF;
    
	-- CURSOR 1: Rango de fechas de la consulta y las páginas
    IF vdIni = '2000-01-01' THEN
		SELECT	vnRegs			AS nRegs,
				vnPagina		AS nPagina,
				vnPaginas		AS nPaginas;
    ELSE
		SELECT 	SUBSTRING(vdIni, 1, 10 )							AS dInicio,
				SUBSTRING(DATE_SUB(vdFin, INTERVAL 1 DAY), 1, 10 )	AS dFin,
				vnRegs			AS nRegs,
				vnPagina		AS nPagina,
				vnPaginas		AS nPaginas;
	END IF;
 
	IF vnRegs > 0 THEN
		SET vnRegIni	= ( vnPagina - 1 ) * kPageSize;
		-- CURSOR 2: Listado de viajes del usuario
		SELECT	uv.pVehiculo			AS	fVehiculo			,	v.cPatente				AS	cPatente
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
		FROM	tUsuarioVehiculo				AS	uv
				INNER JOIN	tVehiculo			AS 	v	ON	v.pVehiculo		= 	uv.pVehiculo
				-- Inicio del Viaje
				INNER JOIN tEvento				AS	ini ON	ini.fVehiculo	= 	uv.pVehiculo
														AND	ini.fTpEvento	=	kEventoInicio
				-- Fin del Viaje
				INNER JOIN tEvento				AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
														AND	fin.fTpEvento	=	kEventoFin
				-- Eventos
				LEFT JOIN  tEvento				AS	eve ON	eve.nIdViaje	=	ini.nIdViaje
														AND	eve.fTpEvento not in ( kEventoInicio, kEventoFin )
		WHERE	uv.pUsuario		=	prm_pUsuario
		AND		ini.tEvento		>=	vdIni
		AND		fin.tEvento		<	vdFin
		GROUP BY	uv.pVehiculo	, v.cPatente		, ini.nIdViaje		,
					ini.cCalle		, fin.cCalle		, ini.cCalleCorta	, fin.cCalleCorta	,
                    ini.tEvento		, fin.tEvento		, ini.nValor		,
					fin.nValor
		ORDER BY 	ini.tEvento DESC
        LIMIT		vnRegIni, kPageSize;
        
	END IF;
END //
