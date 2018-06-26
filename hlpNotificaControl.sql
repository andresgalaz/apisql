DELIMITER //
DROP FUNCTION IF EXISTS fnNow //
CREATE FUNCTION fnNow() RETURNS DATE
BEGIN
	RETURN DATE('2018-05-10');
    -- RETURN DATE(NOW());
END //
DELIMITER ;

-- ================================================================================================
-- Cerfificado de Cobertura, se corre cada 10 minutos
-- Detecta los vehículos a los que no se les ha enviado el PDF de cobertura
SELECT v.pVehiculo, v.cPatente, u.cNombre, u.cEmail, IFNULL(m.desc_vehiculo, 'vehículo') cVehiculo
FROM  tVehiculo v
      JOIN tUsuario u ON u.pUsuario = v.fUsuarioTitular
      JOIN integrity.tMovim m ON m.pMovim = v.fMovimCreacion
WHERE v.bPdfCobertura = '0'
AND IFNULL(v.cPoliza,'VACIO') <> 'TEST'
AND   v.bVigente = '1'
;
-- Una vez enviado el mail se marca como enviado para no volver a enviar el mismo
UPDATE tVehiculo  SET bPdfCobertura = '1' WHERE pVehiculo = ?
;


-- ================================================================================================
-- Busca los endoso de facturación (Prorrogas) que no han sido enviadas, se corre cada 10 minutos
SELECT m.pMovim                                       , m.poliza                   as cPoliza
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
-- AGALAZ: Da un error de UNSIGNED cuando nDiasSinMedicion es mayor a la cantidad de días
-- + "     , datediff(f.dFin, f.dInicio) - f.nDiasUso - f.nDiasSinMedicion               as nDiasSinUso
     , CASE WHEN (datediff(f.dFin, f.dInicio) - f.nDiasUso ) > f.nDiasSinMedicion
          THEN datediff(f.dFin, f.dInicio) - f.nDiasUso - f.nDiasSinMedicion
       ELSE
          0
       END                        as nDiasSinUso                     
 FROM  integrity.tMovim m
       INNER JOIN tVehiculo v ON v.cPatente = m.nro_patente AND v.bVigente = '1'
       INNER JOIN tUsuario  u ON u.pUsuario = v.fUsuarioTitular
       INNER JOIN tFactura  f ON f.pVehiculo = v.pVehiculo
                             AND f.pTpFactura = 1
-- Como la medición se hace 7 días antes del cierre, la fecha de vigencia de la prorroga siempre
-- debería estar dentro rango de fechas de medición
                             AND (f.dFin + INTERVAL 7 DAY) BETWEEN m.fecha_inicio_vig AND m.fecha_vencimiento
 WHERE m.cod_endoso = '9900'
 AND   m.bPdfProrroga = '0'
 ORDER BY cPatente, dEmision desc
;
-- Actualiza la prorroga como enviadsa para evitar un re-envío
UPDATE integrity.tMovim SET bPdfProrroga = '1' WHERE pMovim = ?
;


-- ================================================================================================
-- Busca los movimientos de pólizas que aún no han sido enviadas al cliente (Pólizas nuevas)
-- Se corre cada 10 minutos
SELECT v.pVehiculo, v.cPatente, u.cNombre, u.cEmail
FROM  tVehiculo v
      JOIN tUsuario u ON u.pUsuario = v.fUsuarioTitular
      LEFT JOIN integrity.tMovim m ON m.pMovim = v.fMovimCreacion
WHERE v.bPdfPoliza = '0'
AND   IFNULL(v.cPoliza,'TEST') <> 'TEST'
AND   v.bVigente = '1'
;
-- Actualiza el vehículo para inddicar que la póliza fue enviada, asi evita re-envíos
UPDATE tVehiculo  SET bPdfPoliza = '1' WHERE pVehiculo = ?
;


-- ================================================================================================
-- A Facturar: 2 días al cierre, se corre una vez al día a las 8:30 AM
-- 			NO_SINCRO >= 5 mensaje 1
--          SINO mensaje 2
-- Previamente se corre el proceso que calcula los valores acumulados y las
-- fechas de inicio/fin del periodo.
call prControlCierreTransferenciaInicioDef(0);
-- Lista los vehículos que les falta 2 días por vencer su periodo
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
 WHERE w.nDiasAlCierre = 2
 AND   w.cPoliza is not null
 AND   w.bVigente = '1'
 ;


-- ================================================================================================
-- Al cierre del periodo de facturación que es un días después del término. Se corre una vez 
-- al día a las 8:30 AM
-- Previamente se corre el proceso que calcula los valores acumulados y las
-- fechas de inicio/fin del periodo.
call prControlCierreTransferenciaInicioDef(0);
-- Solo se envía si hay días sin medición
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
 , w.pVehiculo, w.fUsuarioTitular
 , fnNow()
FROM  wMemoryCierreTransf w
   LEFT JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular
-- DIAS AL CIERRE = -1, una día después de cerrado  
WHERE w.nDiasAlCierreAnt = -1
-- Si tiene días sin medición
AND   nDiasNoSincro > 0
AND   w.cPoliza is not null
AND   w.bVigente = '1'
;

-- ================================================================================================
-- Factura todos lo que pasaron el 2do día después del venicmiento del periodo. Se corre una vez 
-- al día a las 8:30 AM
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
 WHERE  ifnull(v.cPoliza,'TEST') <> 'TEST'
 AND    v.bVigente = '1'
 AND    fnFechaCierreIni(v.dIniVigencia, 0) > v.dIniVigencia
 -- Dias al cierre = -3  (3 días después del cierre)
 AND    DATEDIFF(fnFechaCierreIni(v.dIniVigencia, 0),fnNow()) = -3
;


-- ================================================================================================
-- Facturación Parcial, ene l día 13 después del inicio se envía un mail si los dñias sin medición
-- no superan los 7 días. Se corre una vez al día a las 8:30 AM.
SELECT u.pUsuario, v.pVehiculo
      , fnFechaCierreIni(v.dIniVigencia, 0) dInicio
      , fnFechaCierreFin(v.dIniVigencia, 0) dFin
      , v.cPatente
      , IFNULL(v.cMarca, 'vehículo')       cMarca
      , u.cNombre, u.cEmail
 FROM   tVehiculo v
        JOIN tUsuario u ON u.pUsuario = v.fUsuarioTitular
 WHERE  v.cPoliza is not null
 AND    v.bVigente = '1'                   
 AND    fnFechaCierreIni(v.dIniVigencia, 1) >= v.dIniVigencia
 -- 13 días desde el inicio del periodo vigente
 AND    DATEDIFF(fnFechaCierreIni(v.dIniVigencia, 1),fnNow()) = 13
 ;
-- Para determinar los días sin medición se llama al procedure, este es el mismo de la API usada por
-- la APP para determinar, entre otras cosas la cantidad de días sin medición
CALL prScoreVehiculoRangoFecha( ?, 0, null, null, ?, null, false )
; 


-- ================================================================================================
-- No Sincro: Se busca que falten 10 o 20 días al cierre. Se corre una vez al día a las 8:30 AM.
-- Previamente se corre el proceso que calcula los valores acumulados y las
-- fechas de inicio/fin del periodo.
call prControlCierreTransferenciaInicioDef(0);
;
-- Busca los vehículos que les falta 10 o 20 días al cierre del periodo actual
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
 WHERE nDiasAlCierre in ( 10, 20 ) 
 AND   w.nDiasNoSincro > 9  AND   w.cPoliza is not null 
 AND   w.bVigente = '1' 
;

