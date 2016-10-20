DROP VIEW  IF EXISTS vPuntajeSuma;
CREATE VIEW vPuntajeSuma as
 SELECT v.fCuenta
      , ini.nIdViaje   AS nIdViaje , ini.fVehiculo  AS fVehiculo
      , ini.fUsuario   AS fUsuario , ini.tEvento    AS tInicio
      , fin.tEvento    AS tFin     , fin.nValor     AS nKms
	  , sum( case ev.fTpEvento when 3 then ev.nPuntaje else 0 end ) as nSumaPtjeAceleracion
      , sum( case ev.fTpEvento when 4 then ev.nPuntaje else 0 end ) as nSumaPtjeFrenada
      , sum( case ev.fTpEvento when 5 then ev.nPuntaje else 0 end ) as nSumaPtjeVelocidad
   FROM tEvento ini
        INNER JOIN      tVehiculo v   ON v.pVehiculo   = ini.fVehiculo
        INNER JOIN      tEvento   fin ON fin.nIdViaje  = ini.nIdViaje
                                     AND fin.fTpEvento = 2 -- Fin Viaje
		LEFT OUTER JOIN tEvento   ev  ON ev.nIdViaje   = ini.nIdViaje
		                             AND ev.fTpEvento  > 2 -- Distinto de Inicio y Fin
  WHERE ini.fTpEvento = 1 -- Inicio Viaje
 GROUP BY ini.nIdViaje, ini.fVehiculo, ini.fUsuario, ini.tEvento
        , fin.tEvento , fin.nValor
