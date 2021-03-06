/*
Prima Técnica: PT

PT * ( 1.2325036803 ) + 47.83 = prima


-> PT = ( prima - 47.83 ) / 1.2325036803
*/
SELECT m.pMovim, m.NOMBRE, m.APELLIDO, m.NRO_PATENTE, m.FECHA_EMISION,year(m.fecha_inicio_vig) `año`, monthname(m.fecha_inicio_vig) mes, m.fecha_inicio_vig, m.COD_ENDOSO, m.DESC_ENDOSO
     , m.PORCENT_DESCUENTO
     , m.sumaaseg
     , m.prima
     , m.derechoemi, m.ingbrutos, m.impsellados, m.iva, m.impvarios, m.impinternos, m.tasasuper, m.servsoc
     , (m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc) suma_imp
     , ((m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc)/prima ) porc_imp
     , m.prima+ (m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc) premioCalc
     , m.premio
     , round(100 * ( m.prima - 47.83 ) / 1.23250368) / 100  primaTecnica
     , (( m.prima - 47.83 ) / 1.23250368 ) / ( 1 - m.PORCENT_DESCUENTO/100 )   primaTecnicaSinDesc
--     , round( (( m.prima - 47.83 ) / 1.2325036803 ) / ( 1 - m.PORCENT_DESCUENTO/100 ))/30   primaTecnicaSinDesc30
--     , round( (( m.prima - 47.83 ) / 1.2325036803 ) / ( 1 - m.PORCENT_DESCUENTO/100 ))/31   primaTecnicaSinDesc31
     , ((( m.prima - 47.83 ) / 1.23250368 ) / ( 1 - m.PORCENT_DESCUENTO/100 ) + 47.83 ) * 1.23250368 primaSinDesc
	 , (((( m.prima - 47.83 ) / 1.23250368 ) / ( 1 - m.PORCENT_DESCUENTO/100 ) + 47.83 ) * 1.23250368) * (((m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc)/prima )  + 1 ) premioSinDesc
	 , round(m.premio / ( 1 - m.PORCENT_DESCUENTO/100 )) - m.premio ahorro
FROM integrity.tMovim m
where m.premio > 0 -- and m.PORCENT_DESCUENTO is not null
-- AND m.PORCENT_DESCUENTO = 0
AND m.fecha_inicio_vig >= '2017-12-01'
AND m.nro_patente in (
'AB686YD',
'AA467BP',
'EPZ791',
'KXZ633',
'EXM369',
'KZI628',
'MRW848',
'AB844YD',
'LTQ105',
'GOZ716',
'NXL561',

'LTA765',
'AA929DU',
'FUZ056',
'KPI916',
'LDP315',
'MKZ002',
'OJE370',
'FWI555',
'LJL447',
'FST135'
)

order by m.NRO_PATENTE,month(m.fecha_inicio_vig);
-- GROUP BY m.nro_patente, m.PORCENT_DESCUENTO ;

drop table ahorro;

create table ahorro as 
SELECT m.pMovim, m.NOMBRE, m.APELLIDO, m.NRO_PATENTE, m.FECHA_EMISION,year(m.fecha_inicio_vig) `año`, monthname(m.fecha_inicio_vig) mes, m.fecha_inicio_vig, m.COD_ENDOSO, m.DESC_ENDOSO
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
     , a.descInv
     , a.sumaaseg
     , a.prima
     , a.derechoemi, a.impsellados
     , a.suma_imp
     , round(10000*a.suma_imp/prima ) / 100 porc_imp
     , a.prima+ a.suma_imp premioCalc
     , a.premio
     , a.primaTecnica
     , round(a.primaTecnica * descInv )   primaTecnicaSinDesc
     , round(a.prima * descInv ) primaSinDesc
	 , round(a.premio * descInv)  premioSinDesc
	 , round(a.premio * descInv) - a.premio ahorro
from ahorro a
where a.descuento > 20; --  between 1 and 10;
