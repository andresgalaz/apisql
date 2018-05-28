DELIMITER //
-- Crea tabla
DROP TABLE IF EXISTS score.tCtaCte //
CREATE TABLE score.tCtaCte (
  pVehiculo INT NOT NULL,
  pPeriodo DATE NOT NULL,
  pMovim SMALLINT NOT NULL,
  fTpMovim CHAR(2) NOT NULL,
  nPorcentaje DECIMAL(6,4) NOT NULL,
  nMonto DECIMAL(10,2) NOT NULL,
  cObservacion VARCHAR(100),
  fUsuario INT NOT NULL,
  tCreacion timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tModif DATETIME,
  PRIMARY KEY (pVehiculo, pPeriodo, pMovim),
  CONSTRAINT fk_CtaCte_tpMovim FOREIGN KEY (fTpMovim) REFERENCES score.tTpMovimCtaCte (pTpMovimCtaCte),
  CONSTRAINT fk_CtaCte_usuario FOREIGN KEY (fUsuario) REFERENCES xformgen4.tUsuario (pUsuario)
) //
-- Crea Triggers
DROP TRIGGER IF EXISTS trgCtaCteUpd //
CREATE TRIGGER trgCtaCteUpd BEFORE UPDATE
    ON tCtaCte FOR EACH ROW
BEGIN
    SET NEW.tModif = now();
END //

DELIMITER ;

