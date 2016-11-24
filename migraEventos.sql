DROP PROCEDURE IF EXISTS migraEventos;
DELIMITER //
CREATE PROCEDURE migraEventos ( )
BEGIN
	
    DROP TEMPORARY TABLE IF EXISTS tmpEvento;
	CREATE TEMPORARY TABLE tmpEvento AS  
	SELECT w.* 
    FROM   wEvento w 
           INNER JOIN tUsuario  u ON u.pUsuario  = w.fUsuario
           INNER JOIN tVehiculo v ON v.pVehiculo = w.fVehiculo
    WHERE  w.bProcesado=0
	
    INSERT INTO tEvento 
         ( nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, tModif ) 
    SELECT nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT,
           cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario,
           nPuntaje, tModif 
    FROM   tmpEvento; 

    DELETE FROM wEvento 
    WHERE  pEvento in ( select t.pEvento from tmpEvento t );

END //
DELIMITER ;
-- call migraEventos(now());
