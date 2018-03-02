/*
Prima Técnica: PT

PT * ( 1.2325036803 ) + 47.83 = prima


-> PT = ( prima - 47.83 ) / 1.2325036803
*/

DROP VIEW vFacturaProrroga;
CREATE VIEW vFacturaProrroga AS
SELECT	  m.pMovim
-- 		, u.cEmail
-- 		, u.cNombre
		, m.NRO_PATENTE								cPatente
-- 		, v.dIniVigencia
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
-- 		INNER JOIN tVehiculo v	ON v.cPatente = m.nro_patente AND v.bVigente = '1'
-- 		INNER JOIN tUsuario u	ON u.pUsuario = v.fUsuarioTitular
WHERE	m.premio > 0 AND m.porcent_descuento IS NOT NULL
AND     m.codEndoso = '9900'
;
SELECT f.* FROM score.vFacturaProrroga f order by f.cPatente, f.dEmision
;
SELECT f.cPatente, sum( round( f.nAhorro / 10 ) * 10 ) nAhorroAcum FROM score.vFacturaProrroga f
GROUP BY f.cPatente
;
