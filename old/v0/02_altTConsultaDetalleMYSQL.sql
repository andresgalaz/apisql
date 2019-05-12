-- Add/modify columns 
alter table tConsultaDetalle add CALINEACION char(1);
alter table tConsultaDetalle add BFILTRO char(1) default '0' not null;
-- Add comments to the columns 
ALTER TABLE tConsultaDetalle
 CHANGE CALINEACION CALINEACION CHAR(1) COMMENT 'Alineacion Izquierda, Centro y Dereccha, adicional al que existe por defecto',
 CHANGE BFILTRO BFILTRO CHAR(1) NOT NULL DEFAULT '0' COMMENT 'Habilita un filtro para la columna';

-- Create table
create table tConsultaAlineacion
(
  PALINEACION  CHAR(1) not null,
  CDESCRIPCION VARCHAR(40) not null,
  PRIMARY KEY (`PALINEACION`)
);
  
insert into tConsultaAlineacion (palineacion, cdescripcion) values ('I', 'Izquierda');
insert into tConsultaAlineacion (palineacion, cdescripcion) values ('C', 'Centro');
insert into tConsultaAlineacion (palineacion, cdescripcion) values ('D', 'Derecha');

ALTER TABLE tConsultaDetalle
 ADD CONSTRAINT fkConsultaDet_alineacion FOREIGN KEY (CALINEACION) 
 REFERENCES tConsultaAlineacion (PALINEACION) ON UPDATE RESTRICT ON DELETE RESTRICT;

commit;
  
