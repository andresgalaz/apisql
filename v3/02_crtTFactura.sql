DROP TABLE IF EXISTS tFactura;
DROP TABLE IF EXISTS tTpFactura;
CREATE TABLE tTpFactura (
  pTpFactura	smallint(5) unsigned NOT NULL,
  cDescripcion	varchar(20) NOT NULL,
  PRIMARY KEY (pTpFactura)
);
insert tTpFactura (pTpFactura, cDescripcion) values (1, 'Factura');
insert tTpFactura (pTpFactura, cDescripcion) values (2, 'Sin Multa');
insert tTpFactura (pTpFactura, cDescripcion) values (3, 'Descuento Pendiente');

CREATE TABLE tFactura (
	pVehiculo				INTEGER			UNSIGNED	NOT NULL,
	pPeriodo				DATE						NOT NULL,
	pTpFactura				SMALLINT(5)		UNSIGNED	NOT NULL,
	dInicio					DATE						NOT NULL,
	dFin					DATE						NOT NULL,
	dInstalacion			DATE						NOT NULL,
	tUltimoViaje			DATETIME,
	tUltimaSincro			DATETIME,
	nKms					DECIMAL(10,2)	UNSIGNED	NOT NULL	DEFAULT '0.0',
	nKmsPond				DECIMAL(10,2)	UNSIGNED	NOT NULL	DEFAULT '0.0',
	nScore					DECIMAL(10,2)	UNSIGNED	NOT NULL	DEFAULT '0.0',
	nQViajes				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nQFrenada				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nQAceleracion			INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nQVelocidad				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nQCurva					INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nDescuento				DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
	nDescuentoKM			DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
	nDescuentoSinUso		DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
	nDescuentoPunta			DECIMAL( 5,2)				NOT NULL	DEFAULT '0.0',
	nDiasTotal				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nDiasUso				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nDiasPunta				INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	nDiasSinMedicion		INTEGER			UNSIGNED	NOT NULL	DEFAULT '0',
	PRIMARY KEY (pVehiculo, pPeriodo, pTpFactura),
	CONSTRAINT fkFactura_vehiculo	FOREIGN KEY (pVehiculo)		REFERENCES tVehiculo	(pVehiculo),
	CONSTRAINT fkFactura_tpFactura	FOREIGN KEY (pTpFactura)	REFERENCES tTpFactura	(pTpFactura)
)
