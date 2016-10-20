DROP VIEW  IF EXISTS vPuntaje;
CREATE VIEW vPuntaje As
SELECT pun.fCuenta, pun.nIdViaje, pun.fVehiculo, pun.fUsuario
     , pun.tInicio, pun.tFin    , pun.nKms
     , vel.nValor nPtjVelocidad , fre.nValor nPtjFrenada, ace.nValor nPtjAceleracion
FROM vPuntajeSuma AS pun
     LEFT OUTER JOIN tRangoPuntaje vel ON vel.fTpEvento = 3
                 AND vel.nInicio <= pun.nSumaPtjeAceleracion AND pun.nSumaPtjeAceleracion < vel.nFin
     LEFT OUTER JOIN tRangoPuntaje fre ON fre.fTpEvento = 4
                 AND fre.nInicio <= pun.nSumaPtjeAceleracion AND pun.nSumaPtjeAceleracion < fre.nFin
     LEFT OUTER JOIN tRangoPuntaje ace ON ace.fTpEvento = 5
                 AND ace.nInicio <= pun.nSumaPtjeAceleracion AND pun.nSumaPtjeAceleracion < ace.nFin
