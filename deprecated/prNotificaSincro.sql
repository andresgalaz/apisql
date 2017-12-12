DELIMITER //
DROP PROCEDURE IF EXISTS prNotificaSincro //
CREATE PROCEDURE prNotificaSincro ()
BEGIN
	DECLARE vpUsuario			INTEGER;
	DECLARE vpVehiculo			INTEGER;
DECLARE vcPoliza			VARCHAR( 40);
	DECLARE vcPatente			VARCHAR( 40);
	DECLARE vcEmail				VARCHAR(140);
	DECLARE vcNombre			VARCHAR(140);
	DECLARE vtUltTransferencia	DATE;
	DECLARE vtUltViaje			DATE;
	DECLARE vtUltControl		DATE;
	DECLARE vdMaxima			DATE;
	DECLARE vdProximoCierre		DATE; 
	DECLARE vnDiasAlCierre		SMALLINT;
	DECLARE eofCur				INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR
	SELECT w.fUsuarioTitular	pUsuario
		 , w.pVehiculo		
         , w.cPatente	, v.cPoliza
		 , u.cEmail						
         , u.cNombre
		 , DATE(w.tUltTransferencia)	
         , DATE(w.tUltViaje)	
         , DATE(w.tUltControl)
		 , DATE(GREATEST( w.tUltTransferencia, w.tUltViaje, w.tUltControl )) vdMaxima
		 , w.dProximoCierre				
         , DATEDIFF( w.dProximoCierre, NOW()) nDiasAlCierre
	FROM	wMemoryCierreTransf w
		JOIN tUsuario	u ON u.pUsuario		= w.fUsuarioTitular
		JOIN tVehiculo	v ON v.pVehiculo	= w.pVehiculo
 	WHERE	v.bVigente = '1'
	ORDER BY nDiasAlCierre ;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;
    
	-- Crea tabla temporal wMemoryCierreTransf
	CALL prControlCierreTransferenciaInicio();
	OPEN cur;    
	FETCH cur INTO vpUsuario			, vpVehiculo			, vcPatente	, vcPoliza			, vcEmail
				 , vcNombre				, vtUltTransferencia	, vtUltViaje			, vtUltControl
                 , vdMaxima				, vdProximoCierre		, vnDiasAlCierre;
	WHILE NOT eofCur DO
-- 	IF vnDiasAlCierre > 2 THEN
			SELECT vpUsuario			, vpVehiculo			, vcPatente				, vcEmail, vcPoliza;
-- 	END IF;
		FETCH cur INTO vpUsuario			, vpVehiculo			, vcPatente	, vcPoliza				, vcEmail
					 , vcNombre				, vtUltTransferencia	, vtUltViaje			, vtUltControl
					 , vdMaxima				, vdProximoCierre		, vnDiasAlCierre;
	END WHILE;
	CLOSE cur;

END //
