DELIMITER //
DROP PROCEDURE IF EXISTS prFacturador //
CREATE PROCEDURE prFacturador ()
BEGIN

/*
	CREATE TEMPORARY TABLE IF NOT EXISTS wMemoryVehiculosFacturar (
		pVehiculo		INTEGER		 UNSIGNED	 NOT NULL,
		cPatente 		VARCHAR(20)				 NOT NULL,
		cIdDispositivo	VARCHAR(100),
		bVigente		TINYINT(1)				 NOT NULL DEFAULT '1',
		fTpDispositivo	SMALLINT(5)	 UNSIGNED,
		fCuenta			INTEGER		 UNSIGNED	 NOT NULL,
		fUsuarioTitular	INTEGER		 unsigned	 NOT NULL,
		tModif			DATETIME				 NOT NULL,
		dIniVigencia	DATE					 NOT NULL,
		dIniCierre		DATE					 NOT NULL,
		dFinCierre		DATE					 NOT NULL,
		PRIMARY KEY (pVehiculo)
	) ENGINE=MEMORY;

    DELETE FROM wMemoryVehiculosFacturar;

    INSERT INTO wMemoryVehiculosFacturar 
		(	pVehiculo				, cPatente	 				, cIdDispositivo			, bVigente					,
			fTpDispositivo			, fCuenta					, fUsuarioTitular			, tModif					,
			dIniVigencia			,
			dIniCierre				,
			dFinCierre		
		)
	SELECT	v.pVehiculo				, v.cPatente				, v.cIdDispositivo			, v.bVigente				,
			v.fTpDispositivo		, v.fCuenta					, v.fUsuarioTitular			, v.tModif					,
			v.dIniVigencia			,
			score.fnPeriodoActual( v.dIniVigencia, 0 ) dIniCierre,
			score.fnPeriodoActual( v.dIniVigencia, 1 ) dFinCierre
	FROM	score.tVehiculo v
	WHERE	v.fTpDispositivo = 3
	AND		v.cIdDispositivo is not null
	AND		v.bVigente in ('1');
*/
    
	-- Crea tabla temporal para procesar cada vehículo, si existe la limpia
	CALL prCreaTmpScoreVehiculo();

	BEGIN
		DECLARE vpVehiculo			INTEGER;
		DECLARE vcPatente 			VARCHAR(20);
		DECLARE vcIdDispositivo		VARCHAR(100);
		DECLARE vbVigente			TINYINT(1);
		DECLARE vfTpDispositivo		SMALLINT(5);
		DECLARE vfCuenta			INTEGER;
		DECLARE vfUsuarioTitular	INTEGER	;
		DECLARE vtModif				DATETIME;
		DECLARE vdIniVigencia		DATE;
		DECLARE vdIniCierre			DATE;
		DECLARE vdFinCierre			DATE;
        
		DECLARE eofCurVeh INTEGER DEFAULT 0;
		DECLARE curVeh CURSOR FOR
			SELECT	v.pVehiculo				, v.cPatente				, v.cIdDispositivo			, v.bVigente				,
					v.fTpDispositivo		, v.fCuenta					, v.fUsuarioTitular			, v.tModif					,
					v.dIniVigencia			,
					score.fnPeriodoActual( v.dIniVigencia, -2 ) dIniCierre,
					score.fnPeriodoActual( v.dIniVigencia, -1 ) dFinCierre
			FROM	score.tVehiculo v
			WHERE	v.fTpDispositivo = 3
			AND		v.cIdDispositivo is not null
			AND		v.bVigente in ('1');
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;

		OPEN curVeh;
		FETCH curVeh INTO	vpVehiculo		, vcPatente			, vcIdDispositivo	,
							vbVigente		, vfTpDispositivo	, vfCuenta			,
							vfUsuarioTitular, vtModif			, vdIniVigencia		,
							vdIniCierre		, vdFinCierre;
		WHILE NOT eofCurVeh DO
			-- Calcula score y descuento del vehículo
			CALL prCalculaScoreVehiculo( vpVehiculo, vdIniCierre, vdFinCierre );
		
			FETCH curVeh INTO	vpVehiculo		, vcPatente			, vcIdDispositivo	,
								vbVigente		, vfTpDispositivo	, vfCuenta			,
								vfUsuarioTitular, vtModif			, vdIniVigencia		,
								vdIniCierre		, vdFinCierre;
		END WHILE;
		CLOSE curVeh;
	END;
  
	SELECT * FROM wMemoryScoreVehiculo;

END //
