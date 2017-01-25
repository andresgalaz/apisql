DROP VIEW IF EXISTS vCuenta;
CREATE VIEW vCuenta AS
SELECT cta.pCuenta
     , cta.fUsuarioTitular, usr.cEmail
     , IFNULL(cta.cAseguradoNombre, usr.cNombre) AS cAseguradoNombre
     , IFNULL(cta.nAseguradoDoc, usr.nDNI ) 	 AS nAseguradoDoc 
     , cta.cPoliza
     , cta.dIniVigencia, cta.dFinVigencia
     , veh.pVehiculo, veh.cPatente, veh.bVigente
     , MAX(sini.tSiniestro) dUltSiniestro
FROM tCuenta AS cta
     INNER JOIN tVehiculo       AS veh
        ON veh.fCuenta = cta.pCUenta
     INNER JOIN tUsuario        AS usr
        ON usr.pUsuario = veh.fUsuarioTitular
     LEFT OUTER JOIN tSiniestro AS sini 
        ON sini.fVehiculo = veh.pVehiculo
WHERE cta.bVigente = '1'
GROUP BY cta.pCuenta
       , cta.fUsuarioTitular, usr.cEmail
       , IFNULL(cta.cAseguradoNombre, usr.cNombre)
       , IFNULL(cta.nAseguradoDoc, usr.nDNI )
       , cta.cPoliza
       , cta.dIniVigencia, cta.dFinVigencia
       , veh.pVehiculo, veh.cPatente, veh.bVigente
