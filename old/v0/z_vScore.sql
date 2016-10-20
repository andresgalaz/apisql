drop VIEW if exists z_vScore;
create VIEW z_vScore AS 
select s.fVehiculo          as fVehiculo
     , v.cPatente           as cPatente
     , c.fUsuarioTitular    as fUsuarioTitular
     , s.fUsuario           as fUsuario
     , ifNull(u.cNombre, u.cEmail) as cUsuario
     , s.dScore             as dScore
     , s.nValor             as nValor
     , s.nKms               as nKms
from   z_tScore s 
       inner join tUsuario       u  on u.pUsuario  = s.fUsuario
       inner join tCuentaUsuario cu on cu.pUsuario = u.pUsuario
       inner join tCuenta        c  on c.pCuenta   = cu.pCuenta
       inner join tVehiculo      v  on v.pVehiculo = s.fVehiculo
                                   and v.fCuenta   = c.pCuenta;
