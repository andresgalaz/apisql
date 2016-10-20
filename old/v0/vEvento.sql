DROP VIEW IF EXISTS vEvento;
CREATE VIEW vEvento AS
select ev.fVehiculo, ev.nIdViaje, c.fUsuarioTitular, ev.fUsuario, ev.fTpEvento, tp.cDescripcion as cEvento
     , ev.tEvento, ev.nLG, ev.nLT, ev.nValor, ev.nVelocidadMaxima, ev.cCalle as cCalle
from   tEvento ev 
      inner join tTpEvento tp on tp.pTpEvento = ev.fTpEvento
      inner join tCuentaUsuario cu on cu.pUsuario = ev.fUsuario
      inner join tCuenta        c  on c.pCuenta = cu.pCuenta
      inner join tVehiculo      v  on v.pVehiculo = ev.fVehiculo
                                  and v.fCuenta = c.pCuenta
where  ev.fTpEvento in ('3','4','5')                                  
