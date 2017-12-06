SELECT m.pMovim, m.NOMBRE, m.APELLIDO, m.NRO_PATENTE, m.FECHA_EMISION,year(m.fecha_inicio_vig) `año`, monthname(m.fecha_inicio_vig) mes, m.fecha_inicio_vig, m.CODENDOSO, m.DESC_ENDOSO
     , m.PORCENT_DESCUENTO
     , m.sumaaseg, m.prima, m.derechoemi, m.impsellados
     , (m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc) suma_imp
     , round(10000*(m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc)/prima ) / 100 porc_imp
     , m.prima+ (m.derechoemi + m.ingbrutos + m.impsellados + m.iva + m.impvarios+m.impinternos + m.tasasuper + m.servsoc) premioCalc
     , m.premio
     , round(m.prima  / ( 1 - m.PORCENT_DESCUENTO/100 )) primaSinDesc
	 , round(m.premio / ( 1 - m.PORCENT_DESCUENTO/100 ))  premioSinDesc
	 , round(m.premio / ( 1 - m.PORCENT_DESCUENTO/100 )) - m.premio ahorro
FROM integrity.tMovim m
where m.premio > 0 and m.PORCENT_DESCUENTO is not null
order by m.NRO_PATENTE,m.pMovim;
 -- m.nro_patente in ('KJO549','IXF122');
-- GROUP BY m.nro_patente, m.PORCENT_DESCUENTO ;