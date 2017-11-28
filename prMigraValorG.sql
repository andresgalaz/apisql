DELIMITER //
DROP PROCEDURE IF EXISTS prMigraValorG //
CREATE PROCEDURE prMigraValorG ( IN prm_dCorte DATE )
BEGIN
	IF prm_dCorte IS NULL THEN
		SET prm_dCorte = '2017-01-01';
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmpFuerzaG;    
	CREATE TEMPORARY TABLE tmpFuerzaG (
	  pEvento int(11) unsigned NOT NULL DEFAULT '0',
	  nValorG smallint(6) DEFAULT NULL,
      PRIMARY KEY (pEvento)
	);
    
    INSERT INTO tmpFuerzaG 
	SELECT ev.pEvento, snapcar.fnFuerzaG( o.prefix_observation, d.x, d.y ) nValorG
	FROM	score.tEvento ev
			LEFT JOIN snapcar.trip_observations_g	o	ON	o.id			= ev.nIdObservation
			LEFT JOIN snapcar.trip_details			d	ON	d.trip_id		= o.trip_id
														AND	d.event_date	= o.from_time
	WHERE	ev.fTpEvento not in (1,2,5)                                                    
	AND		ev.tEvento > prm_dCorte;

    UPDATE	score.tEvento 
    SET		nValorG = ( SELECT	ABS(nValorG) 
						FROM 	tmpFuerzaG
                        WHERE	tmpFuerzaG.pEvento = tEvento.pEvento 
					  )
	WHERE	fTpEvento not in (1,2,5)
	AND		tEvento > prm_dCorte;

END //

