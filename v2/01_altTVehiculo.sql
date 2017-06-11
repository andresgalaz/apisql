ALTER TABLE tVehiculo ADD dIniVigencia DATE ;
update tVehiculo set dIniVigencia = date(tModif);
ALTER TABLE score.tVehiculo
 CHANGE dIniVigencia dIniVigencia DATE NOT NULL;
