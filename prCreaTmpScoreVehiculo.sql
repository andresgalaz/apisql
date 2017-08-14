DELIMITER //
DROP PROCEDURE IF EXISTS prCreaTmpScoreVehiculo //
CREATE PROCEDURE prCreaTmpScoreVehiculo ()
BEGIN

	-- Tabla temporal de resultados por usuario y vehiculo
	CREATE TEMPORARY TABLE IF NOT EXISTS wMemoryScoreVehiculo (
		pVehiculo				INTEGER			UNSIGNED	NOT NULL,
		-- pUsuario solo se utiliza cuando se cálcula Score del Vehículo
		pUsuario				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		dInicio					DATE						NOT NULL,
		dFin					DATE						NOT NULL,
		nKms					DECIMAL(10,2)	UNSIGNED	NOT NULL	DEFAULT '0.0',
		nScore					DECIMAL(10,2)	UNSIGNED	NOT NULL	DEFAULT '0.0',
		nQViajes				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nQFrenada				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nQAceleracion			INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nQVelocidad				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nQCurva					INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nDescuento				DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
		nDescuentoKM			DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
		nDescuentoSinUso		DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
		nDescuentoPunta			DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
		nDiasTotal				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nDiasUso				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nDiasPunta				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		nDiasSinMedicion		INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
		PRIMARY KEY (pVehiculo, pUsuario)
	) ENGINE=MEMORY;
	DELETE FROM wMemoryScoreVehiculo;

END //
