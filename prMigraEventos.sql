DELIMITER //
DROP PROCEDURE IF EXISTS prMigraEventos //
CREATE PROCEDURE prMigraEventos ( )
BEGIN
	-- SELECT '100 Inicio', now();
    DROP TEMPORARY TABLE IF EXISTS tmpEvento;
    CREATE TEMPORARY TABLE tmpEvento AS  
    SELECT	w.* 
    FROM	wEvento w 
			JOIN tParamCalculo	AS	prm	ON	1 = 1
			JOIN tUsuario		AS	u	ON	u.pUsuario		= w.fUsuario
			JOIN tVehiculo		AS	v	ON	v.pVehiculo		= w.fVehiculo
			JOIN wEvento		AS	fin	ON	fin.nIdViaje	= w.nIdViaje
										AND fin.fTpEvento	= 2
										AND	fin.nValor		> prm.nDistanciaMin
    WHERE	w.tEvento >= '2017-01-01';
	-- WHERE w.tEvento >= '2016-08-01';
	-- SELECT '200 Crea tabla temporal', count(*) from tmpEvento;
    
    -- Elimina los viajes que ya se habían migrado, dado que vienen nuevos eventos
    -- para el mismo viaje. Esto ocurre cuando pasa mucho tiempo entre un evento y otro
    -- del mismo viaje.
	DELETE FROM tEvento
    WHERE  nIdViaje in ( SELECT DISTINCT tmp.nIdViaje
                         FROM   tmpEvento tmp );
	-- SELECT '300 Elimina los viajes que ya existen', now();                     
    INSERT INTO tEvento 
         ( nIdObservation, nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, cCalleCorta, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, nNivelApp, tModif ) 
    SELECT nIdObservation, nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, cCalleCorta, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, nNivelApp, tModif 
    FROM   tmpEvento;

	-- SELECT '400 Inserta eventos', now();
	BEGIN
		DECLARE vnCount		integer DEFAULT 0;
		-- Claves
		DECLARE vnIdViaje	integer;
		-- Cursor Eventos por Viaje
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT DISTINCT w.nIdViaje
			FROM   tmpEvento w;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

	-- SELECT '510 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vnIdViaje;
	-- SELECT '520 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
			-- Calcula Score diario
			-- SET vnCount = vnCount + 1;
			-- IF vnCount % 100 = 0 THEN
				-- SELECT '530 Inicio cursor', now(), vnIdViaje, vnCount;
			-- END IF;
			CALL prCalculaScoreViaje( vnIdViaje );
			FETCH CurEvento INTO vnIdViaje;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
    
	BEGIN
		-- Claves
		DECLARE vpVehiculo	integer;
		DECLARE vpUsuario	integer;
		DECLARE vdFecha	    date;
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Usuario y Fecha de evento
		-- para calcular el score diario
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT DISTINCT w.fVehiculo, w.fUsuario, date( w.tEvento )
			FROM   tmpEvento w;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

		-- SELECT '610 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
        -- SELECT '620 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
			-- Calcula Score diario
			CALL prCalculaScoreDia( vdFecha, vpVehiculo, vpUsuario );
			FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
	-- SELECT '830 Fin cursor', now();

	INSERT INTO wEventoHist
		 ( tProceso			, pEvento	, nIdViaje	, nIdTramo		, fTpEvento
         , tEvento			, nLG		, nLT		, cCalle		, cCalleCorta
         , nVelocidadMaxima	, nValor	, fVehiculo	, fUsuario		, nIdObservation
         , nPuntaje			, nNivelApp	, tModif	)
	SELECT now()			, pEvento	, nIdViaje	, nIdTramo		, fTpEvento
         , tEvento			, nLG		, nLT		, cCalle		, cCalleCorta
         , nVelocidadMaxima	, nValor	, fVehiculo	, fUsuario		, nIdObservation
         , nPuntaje			, nNivelApp	, tModif
	FROM   wEvento;
    /*
	-- Crea una tabla de bitacora de los registros migrados
	SET @tLog=CONCAT('create table integrity.wEvento_',date_format(now(),'%Y%m%d_%H%i'),' as select * from wEvento');
	PREPARE stmt FROM @tLog;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	*/
	-- Limpia tabla temporal
    DELETE FROM wEvento WHERE 1 = 1; 

END //

