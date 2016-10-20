DROP PROCEDURE IF EXISTS calculaScoreByRango;
CREATE PROCEDURE calculaScoreByRango (in dInicio date, in dFin date)
BEGIN
    DECLARE vnIdViaje  integer;
    DECLARE vfVehiculo integer;
    DECLARE vfUsuario  integer;
    DECLARE vtInicio   datetime;
    DECLARE vtFin      datetime;
    DECLARE vnKms      float;

    DECLARE vnPuntajeAceleracion integer;
    DECLARE vnPuntajeFrenada     integer;
    DECLARE vnPuntajeVelocidad   integer;

    DECLARE kEventoInicio      integer DEFAULT 1;
    DECLARE kEventoFin         integer DEFAULT 2;
    DECLARE kEventoAceleracion integer DEFAULT 3;
    DECLARE kEventoFrenada     integer DEFAULT 4;
    DECLARE kEventoVelocidad   integer DEFAULT 5;

    DECLARE eofCursorViaje integer DEFAULT 0;
    DECLARE cursorViaje CURSOR FOR
        SELECT ini.nIdViaje   AS nIdViaje , ini.fVehiculo  AS fVehiculo
             , ini.fUsuario   AS fUsuario , ini.tEvento    AS tInicio
             , fin.tEvento    AS tFin     , fin.nValor     AS nKms
          FROM tEvento ini
               INNER JOIN tEvento fin
                  ON fin.nIdViaje  = ini.nIdViaje AND fin.fTpEvento = kEventoFin
         WHERE ini.fTpEvento = kEventoInicio
           AND fin.tEvento between dInicio and dFin;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCursorViaje = 1;

    -- Limpia area de trabajo
    DELETE FROM wEventoScore;
    -- Recorre cursor de Viajes
    OPEN cursorViaje;
    FETCH cursorViaje INTO vnIdViaje, vfVehiculo, vfUsuario, vtInicio, vtFin, vnKms;
    WHILE NOT eofCursorViaje DO
        SELECT vnIdViaje, vfVehiculo, vfUsuario, vtInicio, vtFin, vnKms;
        SELECT sum( case fTpEvento when kEventoAceleracion then nPuntaje else 0 end ) as nPuntajeAceleracion
             , sum( case fTpEvento when kEventoFrenada     then nPuntaje else 0 end ) as nPuntajeFrenada
             , sum( case fTpEvento when kEventoVelocidad   then nPuntaje else 0 end ) as nPuntajeVelocidad
          INTO vnPuntajeAceleracion, vnPuntajeFrenada, vnPuntajeVelocidad
          FROM tEvento
         WHERE nIdViaje = vnIdViaje;

        INSERT INTO wEventoScore
               ( nIdViaje , nKms , nPuntajeAceleracion , nPuntajeFrenada , nPuntajeVelocidad  )
        VALUES ( vnIdViaje, vnKms, vnPuntajeAceleracion, vnPuntajeFrenada, vnPuntajeVelocidad );
        FETCH cursorViaje INTO vnIdViaje, vfVehiculo, vfUsuario, vtInicio, vtFin, vnKms;
    END WHILE;
    CLOSE cursorViaje;
END;
