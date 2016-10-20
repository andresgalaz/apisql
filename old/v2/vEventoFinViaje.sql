DROP VIEW IF EXISTS vEventoFinViaje;
CREATE VIEW vEventoFinViaje AS
  select  e.tEvento, e.fVehiculo, e.fUsuario, e.nValor
  from    tEvento e
  where   e.fTpEvento = '2'
  and     e.nValor is not null
