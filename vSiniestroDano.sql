CREATE VIEW vSiniestroDano AS
  SELECT sd.pSiniestro, sd.pTpDano, d.cNombre cTpDano
       , case when sd.bExiste = '1' then 'X' else '' end cPresente
  FROM tSiniestroDano sd
  INNER JOIN tTpDano d on d.pTpDano = sd.pTpDano;
