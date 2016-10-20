DROP VIEW IF EXISTS vEvento;
CREATE VIEW vEvento AS
select ev.fVehiculo, ev.nIdViaje, v.fUsuarioTitular, ev.fUsuario, ev.fTpEvento, tp.cDescripcion as cEvento
     , ev.tEvento, ev.nLG, ev.nLT, ev.nValor, ev.nVelocidadMaxima, ev.cCalle as cCalle
from   tEvento ev
      inner join tTpEvento   tp on tp.pTpEvento = ev.fTpEvento
      inner join tVehiculo   v  on v.pVehiculo  = ev.fVehiculo
where  ev.fTpEvento in ('3','4','5')
