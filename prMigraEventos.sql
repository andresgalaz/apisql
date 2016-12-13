DROP PROCEDURE IF EXISTS prMigraEventos;
DELIMITER //
CREATE PROCEDURE prMigraEventos ( )
BEGIN

    -- SELECT '100 Inicio', now();
    
    DROP TEMPORARY TABLE IF EXISTS tmpEvento;
    CREATE TEMPORARY TABLE tmpEvento AS  
    SELECT w.* 
    FROM   wEvento w 
           INNER JOIN tUsuario  u ON u.pUsuario  = w.fUsuario
           INNER JOIN tVehiculo v ON v.pVehiculo = w.fVehiculo;
    -- SELECT '200 Crea tabla temporal', now();
    
    -- Elimina los viajes que ya se habían migrado, dado que vienen nuevos eventos
    -- para el mismo viaje. Esto ocurre cuando pasa mucho tiempo entre un evento y otro
    -- del mismo viaje.
	DELETE FROM tEvento
    WHERE  nIdViaje in ( SELECT DISTINCT tmp.nIdViaje
                         FROM   tmpEvento tmp );
    -- SELECT '300 Elimina los viajes que ya existen', now();
                         
    INSERT INTO tEvento 
         ( nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, tModif ) 
    SELECT nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, tModif 
    FROM   tmpEvento;
    -- SELECT '400 Inserta eventos', now();
    
	BEGIN
		-- Acumuladores
		DECLARE vpVehiculo	integer;
		DECLARE vpUsuario	integer;
		DECLARE vdFecha	    date;
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Usuario y Fecha de evento
		-- para calcular el score diario
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT DISTINCT w.fVehiculo, w.fUsuario, date( w.tEvento )
			FROM   wEvento w
		           INNER JOIN tUsuario  u ON u.pUsuario  = w.fUsuario
		           INNER JOIN tVehiculo v ON v.pVehiculo = w.fVehiculo;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

        -- SELECT '510 Abre cursor', now();
		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
        -- SELECT '520 Inicio cursor', now();
		WHILE NOT eofCurEvento DO
			-- Calcula Score diario
			CALL prCalculaScoreDia( vdFecha, vpVehiculo, vpUsuario );
			FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
    -- SELECT '530 Fin cursor', now();
  
	-- Limpia tabla temporal
    DELETE FROM wEvento 
    -- Por problema con el rendimiento con esta sentencia,
    -- no se guardan los registros no migrados con errores
    WHERE  pEvento in ( select t.pEvento from tmpEvento t );
    -- SELECT '600 Borra registros migrados', now();

END //
DELIMITER ;