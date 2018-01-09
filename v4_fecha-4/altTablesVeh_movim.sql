ALTER TABLE tVehiculo 
ADD COLUMN dIniPoliza DATE NULL AFTER tModif;

ALTER TABLE integrity.tMovim 
ADD COLUMN bPdfPoliza TINYINT(1) NOT NULL DEFAULT '0' AFTER tModif;

update tVehiculo  set dIniPoliza   = dIniVigencia                   where dIniVigencia is not null;
update tVehiculo  set dIniVigencia = dIniVigencia - interval 4 day  where dIniVigencia is not null;

-- Asumimos que todo está impreso
update integrity.tMovim   set bPdfPoliza=1;