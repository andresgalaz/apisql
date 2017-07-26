DROP TABLE IF EXISTS tFirmwareEstado;
CREATE TABLE tFirmwareEstado (
	pFirmwareEstado	int		(11) unsigned	NOT NULL AUTO_INCREMENT,
	fVehiculo		int		(11) unsigned	NOT NULL,
	cEstado			varchar	(50)			NOT NULL,
	cIdDispositivo	varchar	(50)			NOT NULL,
	tModif timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (pFirmwareEstado),
	-- KEY fkFirmwareEstado_vehiculo (fVehiculo),
	CONSTRAINT fkFirmwareEstado_vehiculo FOREIGN KEY (fVehiculo) REFERENCES tVehiculo (pVehiculo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
