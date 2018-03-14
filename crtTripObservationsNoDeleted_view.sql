DROP VIEW IF EXISTS snapcar.trip_observations_no_deleted_view;
CREATE VIEW snapcar.trip_observations_no_deleted_view as
SELECT o.*
FROM snapcar.trip_observations_g  o
WHERE NOT EXISTS ( SELECT 1 FROM snapcar.trip_observations_deleted d WHERE d.id = o.id )
-- WHERE EXISTS ( SELECT 1 FROM score.tEvento d WHERE d.nIdObservation = o.id )
AND o.`status` = 'OK';

# pEvento, nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT, cCalle, cCalleCorta, nVelocidadMaxima, nValor, nValorG, fVehiculo, fUsuario, nIdObservation, nPuntaje, nNivelApp, tModif, bVigente
# '85457', '136467', '1', '3', '2018-02-25 16:34:58', '-58.35921', '-34.66275', '12 de Octubre 275-291, Avellaneda, Bs.As.', 'Avellaneda, Bs.As.', NULL, '32.976', '200', '522', '365', '208406', '1', '1', '2018-02-25 20:14:59', '1'
