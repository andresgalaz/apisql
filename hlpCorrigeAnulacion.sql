DROP TABLE IF EXISTS score.agv 
;
-- Hace fisica la consulta de prNotifica que se usa para crear vehiculos/usuarios
CREATE TABLE score.agv AS
SELECT	m.pMovim											,
		m.NRO_PATENTE						AS cPatente		,
		m.poliza							AS cPoliza		,
		m.FECHA_INICIO_VIG					AS dIniVigencia	,
		m.FECHA_EMISION						AS dEmision		,
		CONCAT( m.NOMBRE, ' ', m.APELLIDO )	AS cNombre		,
		m.TIPO_DOC							AS cTpDoc		,
		m.DOCUMENTO							AS cDocumento	,
		m.MAIL								AS cEmail		,
		m.FECHA_NACIMIENTO					AS dNacimiento	,
		m.COD_MARCA							AS cMarca		,
		m.COD_MODELO						AS cModelo		,
		IFNULL(m.COD_ENDOSO, '0000')		AS cTpEndoso	,
        DESC_ENDOSO
FROM	integrity.tMovim m 
WHERE 	m.MAIL IS NOT NULL
AND		m.NRO_PATENTE <> 'A/D'
AND		m.COD_TIPO_ESTADO in ( '04', '07' ) -- En Inspección y Póliza
--    AND		m.POLIZA IS NOT NULL
--    AND		m.ENDOSO	= '00000'
 AND m.COD_ENDOSO IN (
	 '0053','0052','0917','1205','1486'
	,'3528','3545','3546','9592','9593'
	,'1571','5423'

	-- Anulación por Saldo
	,'1235','0871','1407','1445','3520'
	,'3536','3537','5425'

	-- Anulación Parcial a Prorrata
	,'0952','1367','0443','0339','0470'
	,'0365','1483','3322','3728','3741'
	,'3725','9594','0377' )      
ORDER BY m.NRO_PATENTE, m.pMovim DESC
;
-- Elimina ya comprabados como anulados correctamente
delete from score.agv 
where cPatente in ( 'AC434ZA', 'EPZ791', 'FWI555', 'FYC645', 'ISS673', 'JYM392', 'LQB799' , 'NLF993'
                  , 'OOM918' , 'LEU187', 'LGH390', 'LIZ928', 'LPT144', 'OJD100', 'ONV367' );
-- Si la patente está 2 veces o mas, puede haber un problema
SELECT v.*, a.* FROM score.agv a inner join score.tVehiculo v on v.cPatente = a.cPatente
order by v.cPatente
;