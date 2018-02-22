-- Lista los vehículos en los que la fecha de inicio de vigencia no coincide
SELECT m.pmovim, m.nro_patente, m.CODENDOSO, m.cod_endoso, m.poliza, v.cPoliza, m.fecha_inicio_vig, v.dIniVigencia, datediff(m.fecha_inicio_vig, v.dIniVigencia) nDiff, v.fTpDispositivo, v.cIdDispositivo, v.bVigente, v.tBaja
, m.COD_TIPO_ESTADO, m.MAIL
FROM integrity.tMovim m left join tVehiculo v on v.cPatente = m.nro_patente 
where m.nro_patente not in ('A/D')
and m.poliza is not null
-- Poliza anuladas
and m.poliza not in ('000003071434','000003071995')
and v.bVigente='1'
and datediff(m.fecha_inicio_vig, v.dIniVigencia) <> 0
and ( m.CODENDOSO is NULL OR m.COD_ENDOSO='00000')
order by nro_patente, fecha_inicio_vig;

-- Muestra los movimientos que no tienen vehiculo con la misma poliza
SELECT m.pmovim, m.nro_patente, m.CODENDOSO, m.cod_endoso, m.poliza, m.fecha_inicio_vig, m.COD_TIPO_ESTADO, m.MAIL
FROM integrity.tMovim m 
where m.nro_patente not in ('A/D')
and m.poliza is not null
-- Poliza anuladas
and m.poliza not in ('000003071434','000003071995')
and ( m.CODENDOSO is NULL OR m.COD_ENDOSO='00000')
and not exists ( SELECT '1' 
				 FROM tVehiculo v 
                 WHERE v.cPoliza = m.poliza 
			   )
order by nro_patente, fecha_inicio_vig;

SET @PATENTE='LQB799';

SELECT m.pmovim, m.nro_patente, m.CODENDOSO, m.cod_endoso, m.poliza, v.cPoliza, m.fecha_inicio_vig, v.dIniVigencia, datediff(m.fecha_inicio_vig, v.dIniVigencia) nDiff, v.fTpDispositivo, v.cIdDispositivo, v.bVigente, v.tBaja
, m.COD_TIPO_ESTADO, m.MAIL
FROM integrity.tMovim m left join tVehiculo v on v.cPatente = m.nro_patente and v.bVigente='1'
where m.nro_patente not in ('A/D')
and m.nro_patente like @PATENTE
-- and datediff(m.fecha_inicio_vig, v.dIniVigencia) <> 0
-- and IFNULL(m.CODENDOSO,'0000') in ( '0000','2001','PR00' )
order by nro_patente, fecha_inicio_vig;

select * from tVehiculo where cPatente like @PATENTE;


