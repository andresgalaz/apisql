ALTER TABLE score.tEvento
 ADD nNivelApp SMALLINT(2) UNSIGNED NOT NULL DEFAULT '0' AFTER nPuntaje;

ALTER TABLE score.tEvento
 ADD cCalleCorta VARCHAR(200) AFTER cCalle;
ALTER TABLE score.tEvento
 CHANGE cCalle cCalle VARCHAR(400);

ALTER TABLE score.wEvento
 ADD nNivelApp SMALLINT(2) UNSIGNED NOT NULL DEFAULT '0' AFTER nPuntaje; 
ALTER TABLE score.wEvento
 ADD cCalleCorta VARCHAR(200) AFTER cCalle;
ALTER TABLE score.wEvento
 CHANGE cCalle cCalle VARCHAR(400);

