/*
Prima Técnica: PT

PT * ( 1.232503 ) + 47.83 = prima


-> PT = ( prima - 47.83 ) / 1.232503
*/
SELECT m.pMovim, m.NOMBRE, m.APELLIDO, m.NRO_PATENTE, m.FECHA_EMISION,year(m.fecha_inicio_vig) `año`, monthname(m.fecha_inicio_vig) mes, m.fecha_inicio_vig, m.CODENDOSO, m.DESC_ENDOSO
     , m.PORCENT_DESCUENTO
     , m.sumaaseg
     , m.prima
     , m.derechoemi, m.impsellados
     , (m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc) suma_imp
     , round(10000*(m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc)/prima ) / 100 porc_imp
     , m.prima+ (m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc) premioCalc
     , m.premio
     , round(100 * ( m.prima - 47.83 ) / 1.2325) / 100  primaTecnica
     , (( m.prima - 47.83 ) / 1.2325 ) / ( 1 - m.PORCENT_DESCUENTO/100 )   primaTecnicaSinDesc
--     , round( (( m.prima - 47.83 ) / 1.232503 ) / ( 1 - m.PORCENT_DESCUENTO/100 ))/30   primaTecnicaSinDesc30
--     , round( (( m.prima - 47.83 ) / 1.232503 ) / ( 1 - m.PORCENT_DESCUENTO/100 ))/31   primaTecnicaSinDesc31
     , round(m.prima  / ( 1 - m.PORCENT_DESCUENTO/100 )) primaSinDesc
	 , round(m.premio / ( 1 - m.PORCENT_DESCUENTO/100 ))  premioSinDesc
	 , round(m.premio / ( 1 - m.PORCENT_DESCUENTO/100 )) - m.premio ahorro
FROM integrity.tMovim m
where m.premio > 0 and m.PORCENT_DESCUENTO is not null
AND m.nro_patente in ('AB686YD','AA467BP','EPZ791')
order by m.NRO_PATENTE,m.pMovim;
-- GROUP BY m.nro_patente, m.PORCENT_DESCUENTO ;

select
AB686YD, 2.596,
AA467BP, 3.411,
EPZ791, 1.617,
KXZ633, 2.987,
EXM369, 1.566,
KZI628, 1.789,
MRW848, 1.578,
AB844YD, 2.221,
LTQ105, 2.093,
GOZ716, 1.429,
NXL561, 2.063;

 