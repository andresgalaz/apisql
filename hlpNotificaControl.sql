DELIMITER //
DROP FUNCTION IF EXISTS fnNow //
CREATE FUNCTION fnNow() RETURNS DATE
BEGIN
	RETURN DATE('2018-03-19');
    -- RETURN DATE(NOW());
END //
DELIMITER ;

-- A Facturar: 2 días al cierre
-- 			NO_SINCRO >= 5 mensaje 1
--          SINO mensaje 2
call prControlCierreTransferenciaInicioDef(0);
SELECT w.cPatente
 	 , w.dProximoCierreIni dInicio
	 , w.dProximoCierreFin dFin
	 , w.nDiasNoSincro
	 , u.cEmail, u.cNombre
	 -- Control
	 , w.nDiasAlCierreAnt
	 , w.nDiasAlCierre
	 , w.dIniVigencia
 FROM  wMemoryCierreTransf w
       JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular
 WHERE w.cPatente in ( 'FYC645' )
--       w.nDiasAlCierre between 1 and 6
 AND   w.cPoliza is not null
 AND   w.bVigente = '1'
 ;


 
-- Al cierre del periodo de facturación que es un días después del término, es decir Fecha Fin Periodo
-- DIAS AL CIERRE = -1 
-- Solo se envía si hay días sin medición
call prControlCierreTransferenciaInicioDef(0);
SELECT w.cPatente
	 , DATE_FORMAT(w.dProximoCierreIni, '%d/%m/%Y')    dInicio
	 , DATE_FORMAT(w.dProximoCierreFin, '%d/%m/%Y')    dFin
	 , w.nDiasNoSincro
	 , u.cEmail, u.cNombre                                              cNombre
     , GREATEST( IFNULL(DATE( w.tUltViaje        ), '0000-00-00') 
               , IFNULL(DATE( w.tUltControl      ), '0000-00-00'))      dSincro 
-- Control           
 , w.nDiasAlCierre
 , w.nDiasAlCierreAnt 
 , w.nDiasNoSincro, w.pVehiculo, w.fUsuarioTitular
FROM  wMemoryCierreTransf w
   LEFT JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular
WHERE w.cPatente in ( 'KZI628' )
-- AND   w.nDiasAlCierreAnt between -5 and 5
      
-- AND   nDiasNoSincro > 0
AND   w.cPoliza is not null
AND   w.bVigente = '1'
;

SELECT w.cPatente 
     , DATE_FORMAT(w.dProximoCierreIni, '%d/%m/%Y')    dInicio 
     , DATE_FORMAT(w.dProximoCierreFin, '%d/%m/%Y')    dFin 
     , w.nDiasNoSincro 
     , u.cEmail, u.cNombre                                              cNombre 
     , GREATEST( IFNULL(DATE( w.tUltViaje        ), '0000-00-00') 
               , IFNULL(DATE( w.tUltControl      ), '0000-00-00'))      dSincro 
 FROM  wMemoryCierreTransf w 
       JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular 
 WHERE nDiasAlCierreAnt = ? 
 AND   nDiasNoSincro > 0 
 AND   w.cPoliza is not null 
 AND   w.bVigente = '1' 
;

-- Facturación Administrativa
-- DIAS AL CIERRE -3
SELECT v.pVehiculo
     , v.cPatente
     , v.cPoliza
     , v.fUsuarioTitular
     , u.cNombre, u.cEmail
     , v.dIniVigencia
	 -- Control      
     , DATEDIFF(fnFechaCierreIni(v.dIniVigencia, 0),fnNow()) nDiasAlCierre
     , fnFechaCierreIni(v.dIniVigencia, 0) dInicio
 FROM   tVehiculo v
        JOIN tUsuario u ON u.pUsuario = v.fUsuarioTitular
 WHERE  v.cPoliza is not null
 AND    v.bVigente = '1'
 AND    fnFechaCierreIni(v.dIniVigencia, 0) > v.dIniVigencia
-- Dias al cierre
--  AND    DATEDIFF(fnFechaCierreIni(v.dIniVigencia, 0),fnNow()) = ?
-- TEST
--  AND v.cPatente in ( 'AC156IE','PJT083','FAA680','IAH606','MRW848','LQB799','AB844YD','LTA765','AB686YD','KPB890','KZI628','MZC135' )
;


-- No Sincro: Se busca que falten 10 o 20 días al cierre
call prControlCierreTransferenciaInicioDef(0)
;
SELECT w.cPatente 
, w.dProximoCierreIni		dInicio 
, w.dProximoCierreFin		dFin 
, w.nDiasNoSincro 
, u.cEmail, u.cNombre 
, w.nDiasAlCierre
, GREATEST( IFNULL(DATE( w.tUltViaje        ), '0000-00-00')
  		  , IFNULL(DATE( w.tUltControl      ), '0000-00-00')
		  -- Si no hay registros en la BD TRIPS, entonces NUNCA sincronizó, así es que
		  -- se calcula a partir de la fecha de vigencia
		  , w.dIniVigencia ) dUltimaSincro

 FROM  wMemoryCierreTransf w 
       JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular 
 WHERE 1=1 -- nDiasAlCierre in ( 10, 20? ) 
 AND   w.nDiasNoSincro > 9  AND   w.cPoliza is not null 
 AND   w.bVigente = '1' 
;

-- Endoso Factura
SELECT 
       m.pMovim                                       , m.poliza                   as cPoliza 
     , m.nro_patente              as cPatente         , m.fecha_emision            as dEmision 
     , m.fecha_inicio_vig         as dInicioVig       , m.fecha_vencimiento        as dFinVig 
     , m.sumaaseg                 as nSumaAsegurada   , m.desc_vehiculo            as cVehiculo 
     , round(m.porcent_descuento) as nDescuento       , m.documento                as nDNI 
     , u.cEmail                                       , u.cNombre 
     , f.dInicio                                      , f.dFin 
     , ROUND(f.nKms)              as nKms             , ROUND(f.nScore)            as nScore
     , f.nQViajes                                     , f.nQFrenada 
     , f.nQAceleracion                                , f.nQVelocidad 
     , f.nQCurva                                      , f.nDiasPunta 
     , f.nDiasUso - f.nDiasPunta  as nDiasNoPunta     , f.nDiasSinMedicion 
     , datediff(f.dFin, f.dInicio) - f.nDiasUso - f.nDiasSinMedicion               as nDiasSinUso
     , m.*
 FROM  integrity.tMovim m 
       INNER JOIN tVehiculo v ON v.cPatente = m.nro_patente AND v.bVigente = '1' 
       INNER JOIN tUsuario  u ON u.pUsuario = v.fUsuarioTitular 
       INNER JOIN tFactura  f ON f.pVehiculo = v.pVehiculo 
                             AND f.pTpFactura = 1 
                             AND (f.dFin + INTERVAL 7 DAY) BETWEEN m.fecha_inicio_vig AND m.fecha_vencimiento 
 WHERE m.cod_endoso = '9900' 
 AND   m.bPdfProrroga = '1' 
 AND m.NRO_PATENTE = 'KZI628'
 ORDER BY cPatente, dEmision desc 
;
