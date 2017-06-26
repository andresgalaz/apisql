-- DROP TABLE tInstalacion 
CREATE TABLE tInstalacion (
  pInstalacion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  fUsuario INT UNSIGNED NOT NULL,
  fVehiculo INT UNSIGNED NULL,
  cPatente VARCHAR(20) NULL,
  cIdDispositivo VARCHAR(50) NOT NULL,
  cOpcion VARCHAR(20) NOT NULL,
  cEstado VARCHAR(20) NOT NULL,
  cNumInstalacion VARCHAR(20),
  tModif TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (pInstalacion),
  FOREIGN KEY fkInstalacion_usuario (fUsuario) REFERENCES tUsuario (pUsuario) 
  );
