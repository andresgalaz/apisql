DROP TABLE IF EXISTS score.tCtaCte;
DROP TABLE IF EXISTS score.tTpMovimCtaCte;

CREATE TABLE score.tTpMovimCtaCte (
  pTpMovimCtaCte CHAR(2) NOT NULL,
  cDescripcion VARCHAR(45) NOT NULL,
  PRIMARY KEY (pTpMovimCtaCte));
  
insert into score.tTpMovimCtaCte ( pTpMovimCtaCte, cDescripcion ) values ( 'V', 'Vacaciones con Uso' );
insert into score.tTpMovimCtaCte ( pTpMovimCtaCte, cDescripcion ) values ( 'MD', 'Manual Débito' );
insert into score.tTpMovimCtaCte ( pTpMovimCtaCte, cDescripcion ) values ( 'CD', 'Manual Crébito' );
