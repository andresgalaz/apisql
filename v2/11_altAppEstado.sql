ALTER TABLE `score`.`tAppEstado` 
ADD COLUMN `fVehiculo` INT UNSIGNED NULL AFTER `fUsuario`,
ADD COLUMN `cFirmware` VARCHAR(45) NULL AFTER `cDescripcion`;
