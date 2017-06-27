DROP view if exists vSiniestro;
CREATE VIEW vSiniestro as
SELECT sini.pSiniestro      , sini.fVehiculo        , sini.nLG, sini.nLT
     , sini.tSiniestro      , sini.bLesiones        , veh.cPatente
     , sini.fUsuario        , sini.cObservacion
     , usr.cNombre          as cUsuario
     , veh.fUsuarioTitular  as fUsuarioTitular
     , tit.cNombre          as cUsuarioTitular
FROM tSiniestro sini
     inner join tVehiculo veh on veh.pVehiculo = sini.fVehiculo
     inner join tUsuario usr ON usr.pUsuario = sini.fUsuario
     inner join tUsuario tit ON tit.pUsuario = veh.fUsuarioTitular;
