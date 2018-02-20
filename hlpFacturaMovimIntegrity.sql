-- Verifica que todos los vehículos con POLIZA tengan un movimiento en Integrity
select * from tVehiculo v
where ifnull(cPoliza,'TEST') <> 'TEST'
and   v.bVigente = '1'
and   cPatente not in ( select nro_patente from integrity.tMovim );

-- Verifica que todos los movimientos de Integrity tengan vehículo
select nro_patente, poliza, fecha_emision, cod_endoso, codendoso, desc_endoso from integrity.tMovim
where nro_patente <> 'A/D'
AND nro_patente not in ( select cPatente from tVehiculo );

-- Verificia que exista prorroga dentro del periodo actual
select 'P0',v.pVehiculo, v.cPatente, v.dIniVigencia, fnFechaCierreIni(v.dIniVigencia,-1) dIni_0, fnFechaCierreIni(v.dIniVigencia,0) dIni_1,  fnFechaCierreIni(v.dIniVigencia,1) dIni_2, m.FECHA_INICIO_VIG -- , v.* , m.*
from tVehiculo v
     left join integrity.tMovim m on m.nro_patente = v.cPatente
     and ( m.FECHA_INICIO_VIG between fnFechaCierreIni(v.dIniVigencia,-1) and fnFechaCierreIni(v.dIniVigencia, 0) )
where ifnull(v.cPoliza,'TEST') <> 'TEST'     
and   v.bVigente = '1'
union all
select 'P1',v.pVehiculo, v.cPatente, v.dIniVigencia, fnFechaCierreIni(v.dIniVigencia,-1) dIni_0, fnFechaCierreIni(v.dIniVigencia,0) dIni_1,  fnFechaCierreIni(v.dIniVigencia,1) dIni_2, m.FECHA_INICIO_VIG -- , v.* , m.*
from tVehiculo v
     left join integrity.tMovim m on m.nro_patente = v.cPatente
     and ( m.FECHA_INICIO_VIG between fnFechaCierreIni(v.dIniVigencia,0) and fnFechaCierreIni(v.dIniVigencia, 1) )
where ifnull(v.cPoliza,'TEST') <> 'TEST'     
and   v.bVigente = '1'
order by 1, day(dIniVigencia)
;

-- Lista todos los endosos de un vehículo
select v.pVehiculo, v.cPatente, v.dIniVigencia, m.PORCENT_DESCUENTO, zfnFechaCierreIni(v.dIniVigencia,-1) dIni_0, zfnFechaCierreIni(v.dIniVigencia,0) dIni_1,  zfnFechaCierreIni(v.dIniVigencia,1) dIni_2, m.FECHA_INICIO_VIG -- , v.* , m.*
     , m.CODENDOSO, m.COD_ENDOSO, m.DESC_ENDOSO, m.PREMIO
from tVehiculo v
     left join integrity.tMovim m on m.nro_patente = v.cPatente
--     and m.FECHA_INICIO_VIG between fnFechaCierreIni(v.dIniVigencia,-1) and fnFechaCierreFin(v.dIniVigencia,-1)
where v.cPatente = 'JBH851'
;

select v.pVehiculo, v.cPatente, v.dIniVigencia, zfnFechaCierreIni(v.dIniVigencia,1) dIni , f.dInicio, f.nDescuento
     , v.fTpDispositivo, v.cIdDispositivo, v.fUsuarioTitular, u.cNombre, u.cEmail
     , f.tCreacion
from tFactura f 
	inner join tVehiculo v on v.pVehiculo = f.pVehiculo
    inner join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where f.pTpFactura = 1 AND  f.pVehiculo in ( 438 )
;
