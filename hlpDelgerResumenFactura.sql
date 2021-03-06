SELECT ID_COTIZACION, POLIZA, ENDOSO, FECHA_EMISION, FECHA_INICIO_VIG, FECHA_VENCIMIENTO, COD_COBERTURA, SUMAASEG
     , PRIMA, PREMIO, PORCENT_PROD, VALPRODUCTOR, PORCENT_DESCUENTO, APELLIDO, NOMBRE, PROVINCIA, LOCALIDAD, DESC_FORMA_PAGO
     , NRO_PATENTE, DESC_ENDOSO
FROM integrity.tMovim 
where COD_ENDOSO is NULL 
and poliza in (SELECT poliza FROM integrity.tMovim where COD_ENDOSO = '9900' group by poliza)
union all 
SELECT ID_COTIZACION, POLIZA, ENDOSO, FECHA_EMISION, FECHA_INICIO_VIG, FECHA_VENCIMIENTO, COD_COBERTURA, SUMAASEG
     , PRIMA, PREMIO, PORCENT_PROD, VALPRODUCTOR, PORCENT_DESCUENTO, APELLIDO, NOMBRE, PROVINCIA, LOCALIDAD, DESC_FORMA_PAGO
     , NRO_PATENTE, DESC_ENDOSO
FROM integrity.tMovim where COD_ENDOSO = '9900'
and poliza in (SELECT poliza FROM integrity.tMovim where COD_ENDOSO = '9900' group by poliza)
order by poliza, FECHA_INICIO_VIG
;
SELECT poliza FROM integrity.tMovim where COD_ENDOSO = '9900' group by poliza;
