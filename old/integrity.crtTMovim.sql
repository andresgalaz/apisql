use integrity;
drop table if exists tMovim ;
create table tMovim
( pMovim				INTEGER NOT NULL AUTO_INCREMENT
, tModif				timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
, ID_PRODUCTOR			BIGINT			-- 2412192
, ID_COTIZACION			VARCHAR(20)		-- JNT-0013956490
, POLIZA				VARCHAR(20)		-- 000003069487
, SECCION				VARCHAR(5)		-- 01
, SUBSECCION			VARCHAR(5)		-- 03
, COD_ENDOSO			VARCHAR(5)		-- 00000
, FECHA_EMISION			DATE			-- 2017-07-10T00:00:00-03:00
, FECHA_INICIO_VIG		DATE			-- 2017-07-14T00:00:00-03:00
, FECHA_VENCIMIENTO		DATE			-- 2017-08-14T00:00:00-03:00
, COD_COBERTURA			INTEGER			-- 971
, DESC_COBERTURA		VARCHAR(80) 	-- SNAPCAR - Todo Riesgo
, COT_MONEDA			VARCHAR(5)		-- PES
, SUMAASEG				DECIMAL(12,2)	-- 306000
, DERECHOEMI			DECIMAL(12,2)	-- 0
, INGBRUTOS				DECIMAL(12,2)	-- 0
, IMPSELLADOS			DECIMAL(12,2)	-- 0
, RECARFINAN			DECIMAL(12,2)	-- 0
, PRIMA					DECIMAL(12,2)	-- 1508.48
, PREMIO				DECIMAL(12,2)	-- 1858.44
, IVA					DECIMAL(12,2)	-- 316.78
, IMPVARIOS				DECIMAL(12,2)	-- 15.08
, PORCENT_PROD			DECIMAL( 6,2)	-- 15
, VALPRODUCTOR			DECIMAL(12,2)	-- 226.27
, PORCENT_DESCUENTO		DECIMAL(12,2)	-- 25
, CUOTAS				INTEGER			-- 1
, APELLIDO				VARCHAR(40)		-- GIELCZYNSKY
, NOMBRE				VARCHAR(40)		-- JESSICA DENISE
, SEXO					VARCHAR(20)		-- No informado
, TIPO_DOC				VARCHAR(10)		-- DNI
, DOCUMENTO				INTEGER			-- 32760796
, CALLE					VARCHAR(80)		-- DORREGO
, CALLE_NRO				VARCHAR(10)		-- 1940
, PISO					VARCHAR(20)		-- 2
, DTPO					VARCHAR(20)		-- M
, CP					VARCHAR(10)		-- 1000
, COD_PROVINCIA			VARCHAR(5)		-- 01
, COD_LOCALIDAD			VARCHAR(10)		-- 000716
, PROVINCIA				VARCHAR(80)		-- Capital Federal
, LOCALIDAD				VARCHAR(80)		-- CAPITAL FEDERAL
, MAIL					VARCHAR(80)		-- g.giel@me.com;
, FECHA_NACIMIENTO		DATE			-- 16/10/1986
, COD_REFAC				INTEGER			-- 6
, IMP_CUOTA_1			DECIMAL(12,2)	-- 1858.44
, VTO_CUOTA_1			DATE			-- 2017-07-14T00:00:00-03:00
, IMPINTERNOS			DECIMAL(12,2)	-- 1.51
, TASASUPER				DECIMAL(6,2)	-- 9.05
, SERVSOC				DECIMAL(6,2)	-- 7.54
, COD_FORMA_PAGO		VARCHAR(5)		-- 1005
, DESC_FORMA_PAGO		VARCHAR(80)		-- TARJETA AMERICAN EXPRESS
, FLOTA					VARCHAR(5)		-- 1
, ID_PRODUCTO			VARCHAR(10)		-- 0999
, COD_TIPO_ESTADO		VARCHAR(5)		-- 07
, DESC_TIPO_ESTADO		VARCHAR(40)		-- Poliza Generada
, DESC_VEHICULO			VARCHAR(80)		-- FIAT-500  1.4 CABRIO-[NDR954]
, COD_MARCA				INTEGER			-- 17
, COD_MODELO			INTEGER			-- 742
, ANIO					INTEGER			-- 2013
, NRO_PATENTE			VARCHAR(20)		-- NDR954
, MOTOR					VARCHAR(20)		-- R0DT376437
, CHASSIS				VARCHAR(40)		-- 3C3BFFER0DT376437
, PRIMARY KEY (pMovim)
, UNIQUE INDEX iuMovim_cotizacion (ID_COTIZACION ASC)
)