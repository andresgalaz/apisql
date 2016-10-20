DROP TABLE IF EXISTS `tScoreMes`;
CREATE TABLE `tScoreMes` (
  `pScoreMes`    int(11) NOT NULL AUTO_INCREMENT,
  `fCuenta`   int(11) NOT NULL,
  `dPeriodo`    date NOT NULL,
  `nSumaFrenada`    double NOT NULL,
  `nSumaAceleracion`    double NOT NULL,
  `nSumaVelocidad`    double NOT NULL,
  `nKms` double NOT NULL DEFAULT '0',
  `nFrenada`    double NOT NULL,
  `nAceleracion`    double NOT NULL,
  `nVelocidad`    double NOT NULL,
  `nScore`    double NOT NULL,
  PRIMARY KEY (`pScoreMes`)
) ENGINE=InnoDB;
