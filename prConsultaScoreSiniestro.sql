DELIMITER //

DROP PROCEDURE IF EXISTS prConsultaScoreSiniestro //
CREATE PROCEDURE prConsultaScoreSiniestro( )
BEGIN
	CALL prCreaConsultaScoreSiniestro( null );
	-- Cursor de Salida
	SELECT	  COUNT(*) 'cantPolizas'
			, dPeriodo
			, ROUND(SUM(nScore)/COUNT(*),1) 'scorePromedio'
			, count(idSiniestro) 'cantSiniestros'
			, sum(nKms) 'nKms'
	FROM	wScoreSiniestro
	GROUP BY dPeriodo;

END //

DROP PROCEDURE IF EXISTS prConsultaScoreSiniestroPeriodo //
CREATE PROCEDURE prConsultaScoreSiniestroPeriodo( IN prm_dPeriodo DATE )
BEGIN
	CALL prCreaConsultaScoreSiniestro( prm_dPeriodo );
	-- Cursor de Salida
	SELECT	*
	FROM	wScoreSiniestro;

END //

DROP PROCEDURE IF EXISTS prCreaConsultaScoreSiniestro //
CREATE PROCEDURE prCreaConsultaScoreSiniestro( IN prm_dPeriodo DATE )
BEGIN
	DECLARE vdIni DATE DEFAULT IFNULL( prm_dPeriodo + INTERVAL 1 MONTH                 , DATE( '2016-01-01' ));
	DECLARE vdFin DATE DEFAULT IFNULL( prm_dPeriodo + INTERVAL 2 MONTH - INTERVAL 1 DAY, fnNow()             );
    
	-- Crea una tabla temporal para acumular por Vehículo x Siniestro
	DROP	TEMPORARY TABLE IF EXISTS	wScoreSiniestro;
	CREATE	TEMPORARY TABLE				wScoreSiniestro AS
	SELECT DISTINCT
			  m.pMovim
			, m.poliza						AS cPoliza 
			, m.nro_patente					AS cPatente
			, SUBSTR(m.fecha_inicio_vig - INTERVAL 1 MONTH, 1, 7 )	AS dPeriodo
			, MIN(f.nScore)					AS nScore
			, MAX(f.nKms)					AS nKms
			, s.NUMERO_SINIESTRO			AS idSiniestro
			, s.COVERAGE					AS cTpSiniestro

 	FROM	integrity.tMovim		m 
			INNER JOIN tVehiculo	v	ON	v.cPatente = m.nro_patente
			INNER JOIN tFactura		f	ON	f.pVehiculo = v.pVehiculo 
										AND f.pTpFactura = 1 
										AND (f.dFin + INTERVAL 7 DAY) BETWEEN m.fecha_inicio_vig AND m.fecha_vencimiento 
			LEFT JOIN integrity.tSiniestro s
										ON	s.numero_poliza = m.poliza
										AND SUBSTR(s.fecha_siniestro,1,7) = SUBSTR(m.fecha_inicio_vig,1,7)
										AND s.numero_sub_siniestro='01' 
	WHERE	m.cod_endoso = '9900' 
    AND		m.fecha_inicio_vig BETWEEN vdIni AND vdFin
			-- Esto evita los endosos refacturados - duplicados se muestren 2 veces
	AND		m.pMovim in	(	SELECT	MAX(dup.pMovim)
							FROM	integrity.tMovim dup
							WHERE	dup.premio > 0
							AND		dup.porcent_descuento IS NOT NULL
							AND		dup.cod_endoso = '9900'
							GROUP BY dup.NRO_PATENTE, dup.FECHA_INICIO_VIG, dup.FECHA_VENCIMIENTO
						)
	GROUP BY m.pMovim, m.poliza, m.nro_patente, SUBSTR(m.fecha_inicio_vig,1,7), s.NUMERO_SINIESTRO, s.COVERAGE ;

END //

DELIMITER ;

call prConsultaScoreSiniestro() ;
call prConsultaScoreSiniestroPeriodo(DATE('2017-12-01')) ;


