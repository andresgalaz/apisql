ALTER TABLE `score`.`tFacturaSinMedicion` 
CHANGE COLUMN `nDifDias` `nDiasSinMedicionOriginal` SMALLINT(2) NOT NULL ;
ALTER TABLE `score`.`tFacturaSinMedicion` 
ADD COLUMN `nQAceleracionOriginal` INT NOT NULL DEFAULT '0' AFTER `nDiasSinMedicionOriginal`;
