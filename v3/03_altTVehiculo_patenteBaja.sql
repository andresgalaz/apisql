ALTER TABLE `score`.`tVehiculo` DROP COLUMN `tBaja`;
ALTER TABLE `score`.`tVehiculo` DROP INDEX `idVehiculo_patente`;
ALTER TABLE `score`.`tVehiculo` ADD COLUMN `tBaja` DATETIME DEFAULT '0000-00-00 00:00:00' AFTER `fMovimCreacion`;
ALTER TABLE `score`.`tVehiculo` ADD unique INDEX `idVehiculo_patente` (`cPatente` ASC, `tBaja` ASC);

update `score`.`tVehiculo` set tBaja='0000-00-00 00:00:00' where tBaja is not null;
select * from `score`.`tVehiculo` where cPatente like 'INS%';
select substr(cPatente,1,4) cPatente, count(*) from `score`.`tVehiculo` where tBaja = '0000-00-00 00:00:00' group by substr(cPatente,1,4) order by 2 desc;