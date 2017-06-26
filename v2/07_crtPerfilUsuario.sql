USE score;
CREATE TABLE `tPerfil` (
  `pPerfil` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cDescripcion` VARCHAR(40) NOT NULL,
  `tModif` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `bDefecto` CHAR(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`pPerfil`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
ALTER TABLE `tPerfil` 
ADD UNIQUE INDEX `iuPerfil_descripcion` (`cDescripcion` ASC);
INSERT INTO `score`.`tPerfil` (`cDescripcion`, `bDefecto`) VALUES ('Instalador', '0');

CREATE TABLE `tUsuarioPerfil` (
  `pUsuario` INTEGER UNSIGNED NOT NULL,
  `pPerfil` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`pUsuario`,`pPerfil`),
  KEY `fkUsuarioPerfil_perfil` (`pPerfil`),
  KEY `fkUsuarioPerfil_usuario` (`pUsuario`)  
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO `tUsuarioPerfil` (`pUsuario`,`pPerfil`) VALUES (23,1);
INSERT INTO `tUsuarioPerfil` (`pUsuario`,`pPerfil`) VALUES (77,1);
INSERT INTO `tUsuarioPerfil` (`pUsuario`,`pPerfil`) VALUES (117,1);
