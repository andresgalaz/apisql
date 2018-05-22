drop table agv 
;
create table agv as 
SELECT DISTINCT
       m.pMovim
	 , m.poliza							as cPoliza 
     , m.nro_patente					as cPatente         
     , SUBSTR(m.fecha_inicio_vig - interval 1 month,1,7)	as dPeriodo
     , MAX(f.nScore)					as nScore
     , s.NUMERO_SINIESTRO				as idSiniestro
     , s.COVERAGE						as cTpSiniestro
     
 FROM  integrity.tMovim m 
       INNER JOIN tVehiculo v ON v.cPatente = m.nro_patente -- AND v.bVigente = '1' 
--     INNER JOIN tUsuario  u ON u.pUsuario = v.fUsuarioTitular 
       INNER JOIN tFactura  f ON f.pVehiculo = v.pVehiculo 
                             AND f.pTpFactura = 1 
                             AND (f.dFin + INTERVAL 7 DAY) BETWEEN m.fecha_inicio_vig AND m.fecha_vencimiento 
       LEFT JOIN integrity.tSiniestro s  ON s.numero_poliza = m.poliza
                                        AND SUBSTR(s.fecha_siniestro,1,7) = SUBSTR(m.fecha_inicio_vig,1,7)
                             
 WHERE m.cod_endoso = '9900' 
 -- Esto evita los endosos refacturados - duplicados se muestren 2 veces
 AND   m.pMovim in	  (	SELECT	MAX(dup.pMovim)
						FROM	integrity.tMovim dup
						WHERE	dup.premio > 0 AND dup.porcent_descuento IS NOT NULL
						AND     dup.cod_endoso = '9900'
						GROUP BY dup.NRO_PATENTE,dup.FECHA_INICIO_VIG,dup.FECHA_VENCIMIENTO
					  )                             
 -- ORDER BY cPatente, dEmision desc 
GROUP BY m.pMovim, m.poliza, m.nro_patente, SUBSTR(m.fecha_inicio_vig,1,7), s.NUMERO_SINIESTRO, s.COVERAGE
;

select count(*), coverage cTpSiniestro from integrity.tSiniestro
group by coverage
;
select * from agv w 
-- where w.dPeriodo = '2018-04'
limit 10000
;
select count(*) 'Cantidad Polizas', dPeriodo, round(sum(nScore)/count(*),1) 'Score Promedio', count(idSiniestro) 'Cantidad de Siniestros' from agv
group by dPeriodo;
select count(*), cTpSiniestro from agv group by cTpSiniestro
;

select * from integrity.tMovim m
WHERE m.cod_endoso is null -- OR m.cod_endoso <> '9900' )
;