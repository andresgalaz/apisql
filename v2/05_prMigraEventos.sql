DELIMITER //
DROP PROCEDURE IF EXISTS prMigraEventos //
CREATE PROCEDURE prMigraEventos ( )
BEGIN
--	SELECT '100 Inicio', now();
    DROP TEMPORARY TABLE IF EXISTS tmpEvento;
    CREATE TEMPORARY TABLE tmpEvento AS  
    SELECT w.* 
    FROM   wEvento w 
           INNER JOIN tUsuario  u ON u.pUsuario  = w.fUsuario
           INNER JOIN tVehiculo v ON v.pVehiculo = w.fVehiculo
    WHERE w.tEvento >= '2017-01-01';
--  WHERE w.tEvento >= '2016-08-01';
--	SELECT '200 Crea tabla temporal', now();
    
    -- Elimina los viajes que ya se habían migrado, dado que vienen nuevos eventos
    -- para el mismo viaje. Esto ocurre cuando pasa mucho tiempo entre un evento y otro
    -- del mismo viaje.
	DELETE FROM tEvento
    WHERE  nIdViaje in ( SELECT DISTINCT tmp.nIdViaje
                         FROM   tmpEvento tmp );
--	SELECT '300 Elimina los viajes que ya existen', now();                     
    INSERT INTO tEvento 
         ( nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, cCalleCorta, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, nNivelApp, tModif ) 
    SELECT nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, cCalleCorta, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, nNivelApp, tModif 
    FROM   tmpEvento;

--	SELECT '400 Inserta eventos', now();
	BEGIN
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
--	SELECT '520 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
			-- Calcula Score diario
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

--		SELECT '610 Abre cursor', now();
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

    -- Calcula Score Mensual, solo de los vehículos involucrados, viene después del
    -- cálculo diario porque para calcular el mensual, se utiliza la tabla tScoreDia
	BEGIN
		-- Claves
		DECLARE vpVehiculo	integer;
		DECLARE vcPeriodo	varchar(20);
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Periodo de evento (Dia uno del mes)
		-- para calcular el score mensual
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT DISTINCT concat(substr(( w.tEvento ),1,8),'01'), w.fVehiculo
			FROM   tmpEvento w;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

--		SELECT '710 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vcPeriodo, vpVehiculo;
        -- SELECT '720 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
			-- Calcula Score Mensual
			CALL prCalculaScoreMes( vcPeriodo, vpVehiculo );
			FETCH CurEvento INTO vcPeriodo, vpVehiculo;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos

    -- Calcula Score Mensual por Conductor (usuario), solo de los usuarios involucrados
    -- viene después del cálculo diario porque se utiliza la tabla tScoreDia
	BEGIN
		-- Acumuladores
		DECLARE vpVehiculo	integer;
		DECLARE vpUsuario	integer;
		DECLARE vcPeriodo	varchar(20);
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Periodo de evento (Dia uno del mes)
		-- para calcular el score mensual
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT DISTINCT concat(substr(( w.tEvento ),1,8),'01'), w.fVehiculo, w.fUsuario
			FROM   tmpEvento w;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

--		SELECT '810 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vcPeriodo, vpVehiculo, vpUsuario;
        -- SELECT '820 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
			-- Calcula Score Mes por Condductor
			CALL prCalculaScoreMesConductor( vcPeriodo, vpVehiculo, vpUsuario );
			FETCH CurEvento INTO vcPeriodo, vpVehiculo, vpUsuario;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
    
    -- SELECT '830 Fin cursor', now();
  
	-- Limpia tabla temporal
    DELETE FROM wEvento WHERE 1 = 1; 
    -- WHERE  pEvento in ( select t.pEvento from tmpEvento t );
    -- SELECT '900 Borra registros migrados', now();

END //

