DROP TABLE `tFacturaSinMedicion`
;

CREATE TABLE `tFacturaSinMedicion` (
  `pVehiculo` int(10) unsigned NOT NULL,
  `pPeriodo` date NOT NULL,
  `nDiasSinMedicion` smallint(2) NOT NULL,
  `nDifDias` smallint(2) NOT NULL,
  `cUsuario` varchar(40),
  `tCreacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`pVehiculo`,`pPeriodo`),
  CONSTRAINT `fkFacturaSinMed_vehiculo` FOREIGN KEY (`pVehiculo`) REFERENCES `tVehiculo` (`pVehiculo`)
)
;
