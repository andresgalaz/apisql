/*
Prima Técnica: PT

PT * ( 1.2325036803 ) + 47.83 = prima


-> PT = ( prima - 47.83 ) / 1.2325036803
*/

DROP VIEW vFacturaProrroga;
CREATE VIEW vFacturaProrroga AS
SELECT	  m.pMovim
		, m.NRO_PATENTE								cPatente
		, m.FECHA_EMISION							dEmision
		, m.fecha_inicio_vig						dInicio
		, m.fecha_vencimiento						dFin
		, m.porcent_descuento						nDescuento
		, m.sumaaseg nSumaAsegurada
		, fnRound2(( m.prima - 47.83 ) / 1.2325)	nPrimaTecnica
		, m.prima									nPrima
		, fnRound2(( m.derechoemi + m.ingbrutos 
		  + m.impsellados + m.iva 
		  + m.impvarios+m.impinternos 
		  + m.tasasuper + m.servsoc ) / m.prima)	nPorcImpuestos
		, m.premio									nPremio
--      , 1/ ( 1 - m.porcent_descuento/100 )		nDescuentoInverso
		, ( ( m.prima - 47.83 ) / 1.2325 ) / ( 1 - m.porcent_descuento/100 )		nPrimaTecnicaSD
		, ( ( ( m.prima - 47.83 ) / 1.2325 ) / ( 1 - m.porcent_descuento/100 )
			* 1.2325036803 + 47.83 ) 												nPrimaSD
		, ( ( ( m.prima - 47.83 ) / 1.2325 ) / ( 1 - m.porcent_descuento/100 )
			* 1.2325036803 + 47.83 ) *
		  ( 1 + ( ( m.derechoemi + m.ingbrutos 
				  + m.impsellados + m.iva 
				  + m.impvarios+m.impinternos 
				  + m.tasasuper + m.servsoc ) / m.prima )) 							nPremioSD
		, m.premio
        - ( ( ( m.prima - 47.83 ) / 1.2325 ) / ( 1 - m.porcent_descuento/100 )
		    * 1.2325036803 + 47.83 ) *
		  ( 1 + ( ( m.derechoemi + m.ingbrutos 
		          + m.impsellados + m.iva 
		          + m.impvarios+m.impinternos 
		          + m.tasasuper + m.servsoc ) / m.prima ))							nAhorro
FROM	integrity.tMovim m
WHERE	m.premio > 0 AND m.porcent_descuento IS NOT NULL
AND     m.codEndoso = '9900'
-- Si hay mas de una prorroga para el mismo periodo solo se considera la última, esto porque
-- seguramente las otras son anulaciones
AND		m.pMovim in	  (	SELECT	max(dup.pMovim)
						FROM	integrity.tMovim dup
						WHERE	dup.premio > 0 AND dup.porcent_descuento IS NOT NULL
						AND     dup.codEndoso = '9900'
						GROUP BY dup.NRO_PATENTE,dup.FECHA_INICIO_VIG,dup.FECHA_VENCIMIENTO
					  )
;
SELECT f.* FROM score.vFacturaProrroga f order by f.cPatente, f.dEmision
;
SELECT f.cPatente, sum( round( f.nAhorro / 10 ) * 10 ) nAhorroAcum FROM score.vFacturaProrroga f
GROUP BY f.cPatente
;
