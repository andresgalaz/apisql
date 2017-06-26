DELIMITER //
DROP PROCEDURE IF EXISTS prInstalacion //
CREATE PROCEDURE prInstalacion ( IN prm_pUsuario INTEGER, IN prm_cOpcion VARCHAR(20), IN prm_cEstado VARCHAR(20), IN prm_cId VARCHAR(50), IN prm_cPatente VARCHAR(20), IN prm_cNumInst VARCHAR(20) )
lbPpal:BEGIN
	DECLARE	vpVehiculo		INTEGER;
	DECLARE	vnTpDispositivo	INTEGER;
    DECLARE	vcIdDispositivo	VARCHAR(50);
    DECLARE	vcPatente		VARCHAR(20);

	IF prm_pUsuario IS NULL THEN
		SELECT 3540 nCodigo, 'Usuario no logeado' cMensaje;
		LEAVE lbPpal;
	END IF;
	IF prm_cOpcion IS NULL OR prm_cEstado IS NULL OR prm_cId IS NULL THEN
		SELECT 3542 nCodigo, 'Faltan parámetros' cMensaje;
		LEAVE lbPpal;
	END IF;
	IF prm_cOpcion NOT IN ('instalar','reparar') THEN
		SELECT 3544 nCodigo, 'Opción no válida' cMensaje;
		LEAVE lbPpal;
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
			LEAVE lbPpal;
		END IF;
        
	END IF;
	-- Busca si hay patente asociada al dispositivo
	SELECT	MAX(v.cPatente)
	INTO	vcPatente
	FROM	tVehiculo v
	WHERE	v.cIdDispositivo = prm_cId
    AND		v.fTpDispositivo = 3 -- VIRLOC
	AND		v.bVigente = '1';
    
    -- Instalación
	IF prm_cOpcion = 'instalar' THEN
		IF prm_cPatente IS NULL THEN
			SELECT 3548 nCodigo, 'Debe indicar patente' cMensaje;
			LEAVE lbPpal;
		END IF;
		IF prm_cEstado = 'inicio' THEN
            -- El virloc no puede estar asignado a otra patente
			IF IFNULL(vcPatente,prm_cPatente) <> prm_cPatente THEN
				SELECT 3550 nCodigo, CONCAT('Virloc ya asignado a la patente ',vcPatente) cMensaje;
				LEAVE lbPpal;
			END IF;
		-- ELSEIF prm_cEstado = 'reasignar' THEN
		END IF;
	-- Reparación
	ELSEIF prm_cOpcion = 'reparar' THEN
		IF prm_cEstado = 'inicio' THEN
			-- Pudo no haber indicado patente
			IF prm_cPatente IS NULL THEN
				IF vcPatente IS NOT NULL THEN
					SELECT 3552 nCodigo, CONCAT('Virloc ya asignado a la patente ',vcPatente) cMensaje;
					LEAVE lbPpal;
				END IF;
            ELSE
                -- Si indicó patente el virloc no puede estar en otro vehículo con otra patente
				IF IFNULL(vcPatente,prm_cPatente) <> prm_cPatente THEN
					SELECT 3554 nCodigo, CONCAT('Virloc ya asignado a la patente ',vcPatente) cMensaje;
					LEAVE lbPpal;
				END IF;
			END IF;
		-- ELSEIF prm_cEstado = 'reasignar' THEN
		END IF;
	END IF;

	-- Todo OK
    -- Actualiza dispositivo
	IF prm_cOpcion IN ('instalar','reparar') AND prm_cEstado in ('inicio','reasignar') AND vpVehiculo IS NOT NULL THEN
		IF vcPatente <> prm_cPatente AND prm_cEstado in ('reasignar') THEN
			-- Si es una reasignación, primero limpia el resto de las patentes que pudieran tener el dispositivo
			UPDATE	tVehiculo SET cIdDispositivo = null 
            WHERE	cIdDispositivo = prm_cId 
            AND		fTpDispositivo = 3; -- VIRLOC
        END IF;
		UPDATE tVehiculo SET cIdDispositivo = prm_cId WHERE pVehiculo = vpVehiculo;
    END IF;
    -- Registra acción en la APP del instalador
	INSERT INTO tInstalacion
			( fUsuario		, fVehiculo		, cPatente			, cIdDispositivo	,
			  cOpcion		, cEstado		, cNumInstalacion 	)
	VALUES	( prm_pUsuario	, vpVehiculo	, prm_cPatente		, prm_cId			,
			  prm_cOpcion	, prm_cEstado	, prm_cNumInst		);
    
	SELECT 0 nCodigo, 'OK' cMensaje;

END //


