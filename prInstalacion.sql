DELIMITER //
DROP PROCEDURE IF EXISTS prInstalacion //
CREATE PROCEDURE prInstalacion (	IN prm_pUsuario	INTEGER, 
									IN prm_cAccion	VARCHAR(20),
                                    IN prm_cId		VARCHAR(50),
                                    IN prm_cPatente	VARCHAR(20),
                                    IN prm_cEstado	VARCHAR(20),
                                    IN prm_cNumInst	VARCHAR(20) )
LB_PRINCIPAL:BEGIN
	DECLARE	vpVehiculo			INTEGER;
	DECLARE	vnTpDispositivo		INTEGER;
    DECLARE	vcIdDispositivo		VARCHAR(50);
    DECLARE	vcPatenteDispActual	VARCHAR(20);

	IF prm_pUsuario IS NULL THEN
		SELECT 3540 nCodigo, 'Usuario no logeado' cMensaje;
		LEAVE LB_PRINCIPAL;
	END IF;
	IF prm_cAccion IS NULL OR prm_cAccion NOT IN ('consultar','blanquear','asignar','reasignar','iniciar','finalizar','cancelar') THEN
		SELECT 3542 nCodigo, 'Acción no válida' cMensaje;
		LEAVE LB_PRINCIPAL;
	END IF;
    -- Solo en la consuta se permite no ingresar Id de Dispositivo
	IF prm_cId IS NULL AND prm_cAccion <> 'consultar' THEN
		SELECT 3544 nCodigo, 'Debe indicar ID. de dispositivo' cMensaje;
		LEAVE LB_PRINCIPAL;
	END IF;

	-- Se lee la información del vehículo por patente
	IF prm_cPatente IS NOT NULL THEN
		SELECT	v.pVehiculo	, v.fTpDispositivo, v.cIdDispositivo
		INTO	vpVehiculo	, vnTpDispositivo	, vcIdDispositivo
		FROM	tVehiculo v
		WHERE	v.cPatente = prm_cPatente
		AND		v.bVigente = '1';
        
		IF vpVehiculo IS NULL THEN
			SELECT 3546 nCodigo, CONCAT('La patente ',prm_cPatente,' no existe') cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
        -- Se guarda si es VIRLOC solamente
        IF vnTpDispositivo <> 3 THEN
			SET vcIdDispositivo = null;
        END IF;
        
	END IF;
	-- Busca si hay patente asociada al dispositivo
	SELECT	MAX(v.cPatente)
	INTO	vcPatenteDispActual
	FROM	tVehiculo v
	WHERE	v.cIdDispositivo = prm_cId
    AND		v.fTpDispositivo = 3 -- VIRLOC
	AND		v.bVigente = '1';
    
	IF prm_cAccion = 'consultar' THEN
		IF prm_cId IS NULL AND prm_cPatente IS NULL THEN
			SELECT 3547 nCodigo, 'Debe indicar dispositivo o patente' cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
		-- Consultar: muestra o la patente actualmente asociada al dispositivo, o el dispositivo que tiene la petente
        IF prm_cId IS NULL THEN
			SELECT 0 AS nCodigo, vcIdDispositivo AS cIdDispositivo;
		ELSE
			SELECT 0 AS nCodigo, vcPatenteDispActual AS cPatenteActual;
        END IF;
        LEAVE LB_PRINCIPAL;
    
	ELSEIF prm_cAccion = 'blanquear' THEN
		-- Blanquear: Debe haber indicado Dispositivo
		IF vcPatenteDispActual IS NULL THEN
			SELECT 3548 nCodigo, 'El dispositivo no está asociado a ninguna patente' cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
        -- Pone el nulo el dispositivo en todas las patentes que lo tengan ( debería estar en una sola )
		UPDATE	tVehiculo 
        SET 	cIdDispositivo = null 
		WHERE	cIdDispositivo = prm_cId 
		AND		fTpDispositivo = 3; -- VIRLOC
        
        SET prm_cPatente = vcPatenteDispActual;
        
	ELSEIF prm_cAccion = 'asignar' THEN
		-- Asignar: Debe indicar patente y no debe estar asignado a otra
		IF prm_cPatente IS NULL THEN
			SELECT 3550 nCodigo, 'Debe indicar patente' cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
		-- El virloc no puede estar asignado a otra patente
		IF IFNULL(vcPatenteDispActual,prm_cPatente) <> prm_cPatente THEN
			SELECT 3552 nCodigo, CONCAT('Virloc ya asignado a la patente ',vcPatenteDispActual) cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
		-- La patente no puede tener otro Virloc asignado, para eso usar 'reasignar'
		IF vcIdDispositivo <> prm_cId THEN
			SELECT 3554 nCodigo, CONCAT('La patente tiene otro Virloc, debe reasignar, ID: ', vcIdDispositivo ) cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
        
        -- Actualiza dispositivo del vehículo
		UPDATE tVehiculo SET cIdDispositivo = prm_cId, fTpDispositivo = 3 WHERE pVehiculo = vpVehiculo;
	ELSEIF prm_cAccion = 'reasignar' THEN
		-- Resignar: Debe indicar patente y Debe estar asignado a otra
		IF prm_cPatente IS NULL THEN
			SELECT 3556 nCodigo, 'Debe indicar patente' cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
		-- El virloc no puede estar asignado a otra patente
		IF vcPatenteDispActual <> prm_cPatente THEN
			SELECT 3552 nCodigo, CONCAT('Virloc ya asignado a la patente ',vcPatenteDispActual) cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
        
        -- Actualiza dispositivo del vehículo
		UPDATE tVehiculo SET cIdDispositivo = prm_cId, fTpDispositivo = 3 WHERE pVehiculo = vpVehiculo;

	ELSEIF prm_cAccion in ('iniciar','finalizar','cancelar') THEN
		-- Resignar: Debe indicar patente y Debe estar asignado a otra
		IF prm_cPatente IS NULL THEN
			SELECT 3558 nCodigo, 'Debe indicar patente' cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;

		IF prm_cEstado IS NULL AND prm_cAccion in ('iniciar','finalizar') THEN
			SELECT 3560 nCodigo, 'Debe indicar estado' cMensaje;
			LEAVE LB_PRINCIPAL;
		END IF;
        
        IF NOT EXISTS( SELECT 1 FROM tVehiculo WHERE cPatente = prm_cPatente AND cIdDispositivo = prm_cId AND fTpDispositivo = 3 ) THEN
			SELECT 3562 nCodigo, 'El Virloc no está asociado a la patente' cMensaje;
			LEAVE LB_PRINCIPAL;
        END IF;
        
	END IF;

    -- Registra acción en la APP del instalador
	INSERT INTO tInstalacion
			( fUsuario			, fVehiculo			, cAccion			, 
              cPatente			, cIdDispositivo	, cNumInstalacion 	,
              cEstado			)
	VALUES	( prm_pUsuario		, vpVehiculo		, prm_cAccion		, 
			  prm_cPatente		, prm_cId			, prm_cNumInst		,
              prm_cEstado		);
    
	SELECT 0 nCodigo, 'Ok' cMensaje;

END //
