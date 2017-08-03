DELIMITER //
DROP PROCEDURE IF EXISTS prFirmwareEstado //
CREATE PROCEDURE prFirmwareEstado (	IN prm_pVehiculo INTEGER, IN prm_cFirmware VARCHAR(50), IN prm_cIdDispositivo VARCHAR(50))
LB_PRINCIPAL:BEGIN
	IF prm_pVehiculo IS NULL THEN
		SELECT 3740 nCodigo, 'Debe indicar Id. de vehículo' cMensaje;
		LEAVE LB_PRINCIPAL;
	END IF;
	IF prm_cFirmware IS NULL OR TRIM(prm_cFirmware) = '' THEN
		SELECT 3744 nCodigo, 'Debe indicar Id. de Firmware' cMensaje;
		LEAVE LB_PRINCIPAL;
	END IF;
	IF prm_cIdDispositivo IS NULL OR TRIM(prm_cIdDispositivo) = '' THEN
		SELECT 3744 nCodigo, 'Debe indicar Id. del dispocitivo Virloc' cMensaje;
		LEAVE LB_PRINCIPAL;
	END IF;
    
    IF NOT EXISTS ( SELECT '1' FROM tVehiculo WHERE pVehiculo = prm_pVehiculo ) THEN
		SELECT 3748 nCodigo, 'No existe Id. de vehículo' cMensaje;
		LEAVE LB_PRINCIPAL;
    END IF;

	INSERT INTO tFirmwareEstado ( fVehiculo, cEstado, cIdDispositivo )
    VALUES ( prm_pVehiculo, TRIM(prm_cFirmware), TRIM(prm_cIdDispositivo));

	SELECT 0 nCodigo, 'Ok' cMensaje;

END //
