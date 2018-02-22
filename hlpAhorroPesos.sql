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

drop table ahorro;

create table ahorro as 
SELECT m.pMovim, m.NOMBRE, m.APELLIDO, m.NRO_PATENTE, m.FECHA_EMISION,year(m.fecha_inicio_vig) `año`, monthname(m.fecha_inicio_vig) mes, m.fecha_inicio_vig, m.CODENDOSO, m.DESC_ENDOSO
     , m.PORCENT_DESCUENTO descuento
     , m.sumaaseg
     , m.prima
     , m.derechoemi, m.impsellados
     , (m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc) suma_imp
     , m.premio
     , round(100 * ( m.prima - 47.83 ) / 1.2325) / 100  primaTecnica
     , 1/ ( 1 - m.PORCENT_DESCUENTO/100 )   descInv
FROM integrity.tMovim m
where m.premio > 0 and m.PORCENT_DESCUENTO is not null
-- AND m.nro_patente in ('AB686YD','AA467BP','EPZ791')
order by m.NRO_PATENTE,m.pMovim;

SELECT a.pMovim, concat(a.NOMBRE,' ', a.APELLIDO) nombre, a.NRO_PATENTE patente, a.FECHA_EMISION
     , a.descuento
     , a.sumaaseg
     , a.prima
     , a.derechoemi, a.impsellados
     , a.suma_imp
     , round(10000*a.suma_imp/prima ) / 100 porc_imp
     , a.prima+ a.suma_imp premioCalc
     , a.premio
     , a.primaTecnica
     , ( a.primaTecnica * descInv )   primaTecnicaSinDesc
     , round(a.prima * descInv ) primaSinDesc
	 , round(a.premio * descInv)  premioSinDesc
	 , round(a.premio * descInv) - a.premio ahorro
from ahorro a
where a.descuento = 0;
