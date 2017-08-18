use score;

DROP TABLE IF EXISTS tNotificacionUsuario;
DROP TABLE IF EXISTS tNotificacion;

CREATE TABLE tNotificacion (
  pNotificacion	INT UNSIGNED AUTO_INCREMENT NOT NULL,
  cMensaje		TEXT NOT NULL,
  tModif		timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (pNotificacion));

CREATE TABLE tNotificacionUsuario (
  pNotificacion INT UNSIGNED NOT NULL,
  pUsuario		INT UNSIGNED NOT NULL,
  PRIMARY KEY (pNotificacion,pUsuario));
  
  
ALTER TABLE tNotificacionUsuario
 ADD CONSTRAINT fkNotifUsr_notif FOREIGN KEY (pNotificacion) REFERENCES tNotificacion (pNotificacion) ON UPDATE RESTRICT ON DELETE RESTRICT,
 ADD CONSTRAINT fkNotifUsr_usr   FOREIGN KEY (pUsuario)		 REFERENCES tUsuario (pUsuario) ON UPDATE RESTRICT ON DELETE RESTRICT;
