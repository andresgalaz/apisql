-- Elimina FKs
ALTER TABLE tCuentaUsuario
 DROP FOREIGN KEY fkCuentaUsuario_cuenta,
 DROP FOREIGN KEY fkCuentaUsuario_usuario;

ALTER TABLE tCuenta
 DROP FOREIGN KEY fkCuenta_usuarioTitular;
 
ALTER TABLE tEvento
 DROP FOREIGN KEY fkEvento_usuario,
 DROP FOREIGN KEY fkEvento_vehiculo;
 
ALTER TABLE tInvitacion
 DROP FOREIGN KEY fkInvitacion_cuenta;

ALTER TABLE tInvitacionVehiculo
 DROP FOREIGN KEY fkInvitacionVehiculo_invitacion,
 DROP FOREIGN KEY fkInitacionVehiculo_vehiculo;

ALTER TABLE tVehiculo
 DROP FOREIGN KEY fkVehiculo_tpDispositivo,
 DROP FOREIGN KEY fkVehiculo_cuenta;

-- Hace los cambios
drop table if exists wPuntaje;
drop table if exists z_tScore;
drop view if exists z_vScore;
DROP VIEW  IF EXISTS vPuntajeSuma;
DROP VIEW  IF EXISTS vPuntaje;

ALTER TABLE tUsuario
 CHANGE pUsuario pUsuario INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
 CHANGE nDNI nDNI INT(11) UNSIGNED;

ALTER TABLE tCuenta
 CHANGE pCuenta pCuenta INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
 CHANGE fUsuarioTitular fUsuarioTitular INT(11) UNSIGNED COMMENT 'Columna redundante, se puede calcular';
 
ALTER TABLE tEvento
 CHANGE pEvento pEvento INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
 CHANGE nIdViaje nIdViaje INT(11) UNSIGNED NOT NULL,
 CHANGE nIdTramo nIdTramo INT(11) UNSIGNED NOT NULL,
 CHANGE nVelocidadMaxima nVelocidadMaxima DOUBLE UNSIGNED,
 CHANGE fVehiculo fVehiculo INT(11) UNSIGNED NOT NULL,
 CHANGE fUsuario fUsuario INT(11) UNSIGNED NOT NULL;
 
ALTER TABLE tInvitacion
 CHANGE pInvitacion pInvitacion INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
 CHANGE fCuenta fCuenta INT(11) UNSIGNED NOT NULL;

ALTER TABLE tInvitacionVehiculo
 CHANGE pInvitacion pInvitacion INT(11) UNSIGNED NOT NULL,
 CHANGE pVehiculo pVehiculo INT(11) UNSIGNED NOT NULL;

ALTER TABLE tRangoPuntaje
 DROP FOREIGN KEY fkRangoPtje_tpEvento,
 CHANGE pRangoPuntaje pRangoPuntaje INT(11) UNSIGNED NOT NULL,
 CHANGE nInicio nInicio INT(11) UNSIGNED NOT NULL,
 CHANGE nFin nFin INT(11) UNSIGNED NOT NULL;

ALTER TABLE tScoreMes
 CHANGE pScoreMes pScoreMes INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
 CHANGE fCuenta fCuenta INT(11) UNSIGNED NOT NULL,
 CHANGE nSumaFrenada nSumaFrenada DOUBLE UNSIGNED NOT NULL,
 CHANGE nSumaAceleracion nSumaAceleracion DOUBLE UNSIGNED NOT NULL,
 CHANGE nSumaVelocidad nSumaVelocidad DOUBLE UNSIGNED NOT NULL,
 CHANGE nKms nKms DOUBLE UNSIGNED NOT NULL DEFAULT '0',
 CHANGE nFrenada nFrenada DOUBLE UNSIGNED NOT NULL,
 CHANGE nAceleracion nAceleracion DOUBLE UNSIGNED NOT NULL,
 CHANGE nVelocidad nVelocidad DOUBLE UNSIGNED NOT NULL,
 CHANGE nScore nScore DOUBLE UNSIGNED NOT NULL;

ALTER TABLE tTpDispositivo
 CHANGE pTpDispositivo pTpDispositivo SMALLINT(6) UNSIGNED NOT NULL;

ALTER TABLE tVehiculo
 CHANGE pVehiculo pVehiculo INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
 CHANGE fTpDispositivo fTpDispositivo SMALLINT(6) UNSIGNED,
 CHANGE fCuenta fCuenta INT(11) UNSIGNED NOT NULL;

drop table if exists tUsuarioVehiculo;
CREATE TABLE tUsuarioVehiculo (
   pUsuario INT(11) UNSIGNED NOT NULL,
   pVehiculo INT(11) UNSIGNED NOT NULL,
   fUsuarioTitular INT(11) UNSIGNED NOT NULL,
   tActiva TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (pUsuario, pVehiculo)
) ENGINE = InnoDB ROW_FORMAT = DEFAULT;

DROP TABLE if exists tUsuarioVehiculoHist;
CREATE TABLE tUsuarioVehiculoHist (
   pHistoria INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
   pUsuario INT(11) UNSIGNED NOT NULL,
   pVehiculo INT(11) UNSIGNED NOT NULL,
   fUsuarioTitular INT(11) UNSIGNED NOT NULL,
   tActiva TIMESTAMP NULL,
   tElimina TIMESTAMP NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY (pHistoria)
) ENGINE = InnoDB ROW_FORMAT = DEFAULT;

DELIMITER //
CREATE TRIGGER trgUsuarioVehiculoDel BEFORE DELETE
    ON tUsuarioVehiculo FOR EACH ROW
BEGIN
    -- Guarda la historia para uso futuro
    INSERT INTO tUsuarioVehiculoHist (pUsuario, pVehiculo, fUsuarioTitular, tActiva )
    VALUES ( OLD.pUsuario, OLD.pVehiculo, OLD.fUsuarioTitular, OLD.tActiva );    
END //
DELIMITER ;


-- Crea FK
ALTER TABLE tCuenta
 ADD CONSTRAINT fkCuenta_usuarioTitular FOREIGN KEY (fUsuarioTitular) REFERENCES tUsuario (pUsuario) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tTpDispositivo
 CHANGE pTpDispositivo pTpDispositivo SMALLINT(6) UNSIGNED NOT NULL;

ALTER TABLE tVehiculo
 ADD CONSTRAINT fkVehiculo_tpDispositivo FOREIGN KEY (fTpDispositivo) REFERENCES tTpDispositivo (pTpDispositivo) ON UPDATE RESTRICT ON DELETE RESTRICT,
 ADD CONSTRAINT fkVehiculo_cuenta FOREIGN KEY (fCuenta) REFERENCES tCuenta (pCuenta) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tUsuarioVehiculo
 ADD CONSTRAINT fkUsuarioVehiculo_usr FOREIGN KEY (pUsuario) REFERENCES tUsuario (pUsuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
 ADD CONSTRAINT fkUsuarioVehiculo_usrTit FOREIGN KEY (fUsuarioTitular) REFERENCES tUsuario (pUsuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
 ADD CONSTRAINT fkUsuarioVehiculo_veh FOREIGN KEY (pVehiculo) REFERENCES tVehiculo (pVehiculo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tEvento
 ADD CONSTRAINT fkEvento_usuario FOREIGN KEY (fUsuario) REFERENCES tUsuario (pUsuario) ON UPDATE RESTRICT ON DELETE RESTRICT,
 ADD CONSTRAINT fkEvento_vehiculo FOREIGN KEY (fVehiculo) REFERENCES tVehiculo (pVehiculo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tInvitacionVehiculo
 ADD CONSTRAINT fkInvitacionVehiculo_invitacion FOREIGN KEY (pInvitacion) REFERENCES tInvitacion (pInvitacion) ON UPDATE CASCADE ON DELETE CASCADE,
 ADD CONSTRAINT fkInitacionVehiculo_vehiculo FOREIGN KEY (pVehiculo) REFERENCES tVehiculo (pVehiculo) ON UPDATE CASCADE ON DELETE CASCADE;

