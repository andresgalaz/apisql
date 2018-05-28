-- Verifica que todos los vehículos con POLIZA tengan un movimiento en Integrity
select * from tVehiculo v
where ifnull(cPoliza,'TEST') <> 'TEST'
and   v.bVigente = '1'
and   cPatente not in ( select nro_patente from integrity.tMovim );

-- Verifica que todos los movimientos de Integrity tengan vehículo
select nro_patente, poliza, fecha_emision, endoso, cod_endoso, desc_endoso from integrity.tMovim
where nro_patente <> 'A/D'
AND nro_patente not in ( select cPatente from tVehiculo );

-- Verificia que exista prorroga dentro del periodo actual
drop table if exists wHlpFacturaMovim;
create table wHlpFacturaMovim as
select 'P0' periodo,v.pVehiculo, v.cPatente, v.dIniVigencia, fnFechaCierreIni(v.dIniVigencia,-1) dIni, fnFechaCierreIni(v.dIniVigencia,0) dFin, m.FECHA_INICIO_VIG -- , v.* , m.*
from tVehiculo v
     left join integrity.tMovim m on m.nro_patente = v.cPatente
     and ( m.FECHA_INICIO_VIG between fnFechaCierreIni(v.dIniVigencia,-1) and fnFechaCierreIni(v.dIniVigencia, 0) )
where ifnull(v.cPoliza,'TEST') <> 'TEST'     
and   v.bVigente = '1'
union all
select 'P1',v.pVehiculo, v.cPatente, v.dIniVigencia, fnFechaCierreIni(v.dIniVigencia,0) dIni,  fnFechaCierreIni(v.dIniVigencia,1) dFin, m.FECHA_INICIO_VIG -- , v.* , m.*
from tVehiculo v
     left join integrity.tMovim m on m.nro_patente = v.cPatente
     and ( m.FECHA_INICIO_VIG between fnFechaCierreIni(v.dIniVigencia,0) and fnFechaCierreIni(v.dIniVigencia, 1) )
where ifnull(v.cPoliza,'TEST') <> 'TEST'     
and   v.bVigente = '1'
;

select * from wHlpFacturaMovim 
where FECHA_INICIO_VIG is null
and dIniVigencia <= dFin
order by periodo, day(dIniVigencia);

-- Lista todos los endosos de un vehículo
select v.pVehiculo, v.cPatente, v.dIniVigencia, m.PORCENT_DESCUENTO, fnFechaCierreIni(v.dIniVigencia,-1) dIni_0, fnFechaCierreIni(v.dIniVigencia,0) dIni_1,  fnFechaCierreIni(v.dIniVigencia,1) dIni_2, m.FECHA_INICIO_VIG, m.FECHA_VENCIMIENTO -- , v.* , m.*
     , m.COD_ENDOSO, m.ENDOSO, m.DESC_ENDOSO, m.PREMIO, m.tModif
from tVehiculo v
     left join integrity.tMovim m on m.nro_patente = v.cPatente
--     and m.FECHA_INICIO_VIG between fnFechaCierreIni(v.dIniVigencia,-1) and fnFechaCierreFin(v.dIniVigencia,-1)
where v.cPatente in ( 'AC156IE')
;

select v.pVehiculo, v.cPatente, v.dIniVigencia, zfnFechaCierreIni(v.dIniVigencia,1) dIni, f.dInicio, f.nDescuento
     , v.fTpDispositivo, v.cIdDispositivo, v.fUsuarioTitular, u.cNombre, u.cEmail
     , f.tCreacion
from tFactura f 
	left join tVehiculo v on v.pVehiculo = f.pVehiculo
    left join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where f.pTpFactura = 1 AND  f.pVehiculo in ( 437 )
;


SELECT * FROM integrity.tMovim m 
where  m.nro_patente in ( 'HIC629')
;
SELECT * FROM score.tFactura f
where  f.pVehiculo in ( select v.pVehiculo from tVehiculo v where  v.cPatente in ( 'HIC629'))
;
