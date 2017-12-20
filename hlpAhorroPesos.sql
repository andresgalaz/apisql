/*
Prima Técnica: PT

PT * ( 1.2325036803 ) + 47.83 = prima


-> PT = ( prima - 47.83 ) / 1.2325036803
*/
SELECT m.pMovim, m.NOMBRE, m.APELLIDO, m.NRO_PATENTE, m.FECHA_EMISION,year(m.fecha_inicio_vig) `año`, monthname(m.fecha_inicio_vig) mes, m.fecha_inicio_vig, m.CODENDOSO, m.DESC_ENDOSO
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
where m.premio > 0 and m.PORCENT_DESCUENTO is not null
AND month(m.fecha_inicio_vig) in (11,12)
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
NXL561, 2.063

LTA765, 1.952,
AA929DU, 3287,
FUZ056, 2.062,
KPI916, 3.191,
LDP315, 3.555,
MKZ002, 1.490,
OJE370, 2.146,
FWI555, 1.529,
LJL447, 1.930,
FST135, 1.556;
