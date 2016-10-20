DROP TABLE IF EXISTS tScoreMesConductor;
CREATE TABLE tScoreMesConductor (
  pScoreMesConductor     int(11) NOT NULL AUTO_INCREMENT,
  dPeriodo               date NOT NULL,
  fUsuario               int(11) UNSIGNED not null,
  fVehiculo              int(11) UNSIGNED not null,
  nScore                 double NOT NULL,
  nKms                   double NOT NULL DEFAULT '0',
  nSumaFrenada           double NOT NULL,
  nSumaAceleracion       double NOT NULL,
  nSumaVelocidad         double NOT NULL,
  nFrenada               double NOT NULL,
  nAceleracion           double NOT NULL,
  nVelocidad             double NOT NULL,
  nDiasPunta             smallint(5) UNSIGNED not null default '0',
  nTotalDias             smallint(5) UNSIGNED not null default '0',
  nDiasUso               smallint(5) UNSIGNED not null default '0',
  PRIMARY KEY (pScoreMesConductor)
) ENGINE=InnoDB;
