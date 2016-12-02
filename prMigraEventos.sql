DROP PROCEDURE IF EXISTS prMigraEventos;
DELIMITER //
CREATE PROCEDURE prMigraEventos ( )
BEGIN
	
    DROP TEMPORARY TABLE IF EXISTS tmpEvento;
    CREATE TEMPORARY TABLE tmpEvento AS  
    SELECT w.* 
    FROM   wEvento w 
           INNER JOIN tUsuario  u ON u.pUsuario  = w.fUsuario
           INNER JOIN tVehiculo v ON v.pVehiculo = w.fVehiculo;
	
    INSERT INTO tEvento 
         ( nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, tModif ) 
    SELECT nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, tModif 
    FROM   tmpEvento;
    
	BEGIN
		-- Acumuladores
		DECLARE vpVehiculo	integer;
		DECLARE vpUsuario	integer;
		DECLARE vdFechga	date;
		-- Cursor Eventos
		-- Busca los registros unicos de Vehiculo, Usuario y Fecha de evento
		-- para calcular el score diario
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT UNIQUE w.pVehiculo, w.pUsuario, date( w.tEvento )
			FROM   wEvento w
		           INNER JOIN tUsuario  u ON u.pUsuario  = w.fUsuario
		           INNER JOIN tVehiculo v ON v.pVehiculo = w.fVehiculo;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
		WHILE NOT eofCurEvento DO
			-- Calcula Score diario
			CALL prCalculaScoreDia( vdFecha, vpVehiculo, vpUsuario );
			FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
  
	-- Limpia tabla temporal
    DELETE FROM wEvento 
    WHERE  pEvento in ( select t.pEvento from tmpEvento t );

END //
DELIMITER ;

