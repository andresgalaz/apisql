DROP FUNCTION fnNotificaFacturaDet;
DROP FUNCTION fnPeriodoActual;

ALTER TABLE integrity.tMovim 
ADD COLUMN bPdfPoliza TINYINT(1) NOT NULL DEFAULT '0' AFTER tModif;

ALTER TABLE tFactura 
CHANGE COLUMN dInstalacion dInstalacion DATE NULL ;

-- Asumimos que todo está impreso
update integrity.tMovim   set bPdfPoliza=1;

-- Arregla la fecha de Instalación
update	tVehiculo
set		dInstalacion = dIniVigencia
where	dInstalacion is null 
and 	fTpDispositivo = 3 
and		cIdDispositivo is not null 
and		bVigente = '1';
