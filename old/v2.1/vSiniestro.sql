drop view if exists vSiniestro;
create view vSiniestro as
select sini.pSiniestro      , sini.fVehiculo        , sini.nLG, sini.nLT
     , sini.tSiniestro      , sini.bLesiones        , veh.cPatente         
     , sini.fUsuario                       , usr.cNombre    cUsuario
     , veh.fUsuarioTitular  fUsuarioTitular, tit.cNombre    cUsuarioTitular
from tSiniestro sini
     inner join tVehiculo veh on veh.pVehiculo = sini.fVehiculo
--     inner join tUsuarioVehiculo uVeh on uVeh.pUsuario = sini.fUsuario
     inner join tUsuario usr ON usr.pUsuario = sini.fUsuario
     inner join tUsuario tit ON tit.pUsuario = veh.fUsuarioTitular
