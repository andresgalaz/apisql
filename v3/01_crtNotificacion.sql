CREATE TABLE `tTpNotificacion` (
  `pTpNotificacion` smallint(5) unsigned NOT NULL,
  `cDescripcion` varchar(20) NOT NULL,
  `cEmails` VARCHAR(90),
  PRIMARY KEY (`pTpNotificacion`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO `score`.`tTpNotificacion` (`pTpNotificacion`, `cDescripcion`) VALUES ('1', 'Crea Usuario');

CREATE TABLE `tNotificacion` (
  `pNotificacion` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cMensaje` text COLLATE utf8_unicode_ci NOT NULL,
  `tModif` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tEnviado` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fTpNotificacion` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`pNotificacion`),
  KEY `fk_Notificacion_tpNotif_idx` (`fTpNotificacion`),
  CONSTRAINT `fk_Notificacion_tpNotif` FOREIGN KEY (`fTpNotificacion`) REFERENCES `tTpNotificacion` (`pTpNotificacion`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
