DROP TABLE IF EXISTS AGV;

SET @DCORTE = '2017-01-01';  -- DATE(NOW()) - INTERVAL 1 MONTH;

SELECT @DCORTE;

CREATE TABLE AGV AS
SELECT ev.pEvento, snapcar.fnFuerzaG( o.prefix_observation, d.x, d.y ) nValorG
FROM	score.tEvento ev
		LEFT JOIN snapcar.trip_observations_g	o	ON	o.id			= ev.nIdObservation
		LEFT JOIN snapcar.trip_details			d	ON	d.trip_id		= o.trip_id
													AND	d.event_date	= o.from_time
WHERE	ev.fTpEvento not in (1,2,5)                                                    
AND		ev.tEvento > @DCORTE;

ALTER TABLE AGV
CHANGE COLUMN pEvento pEvento INT UNSIGNED NOT NULL ,
ADD PRIMARY KEY (pEvento);

-- UPDATE score.tEvento set nValorG = null;

UPDATE score.tEvento set nValorG = ( SELECT ABS(nValorG) from AGV WHERE AGV.pEvento = tEvento.pEvento )
WHERE	fTpEvento not in (1,2,5)
AND		tEvento >  @DCORTE;

SELECT count(*) FROM AGV
UNION ALL
SELECT count(*) FROM AGV WHERE nValorG is null
UNION ALL
SELECT count(*) FROM AGV WHERE nValorG is not null;

DROP TABLE IF EXISTS AGV;
-- SELECT * FROM AGV;
call prMigraValorG( DATE(NOW()) - INTERVAL 1 MONTH );
-- select DATE(NOW()) - INTERVAL 7 DAY;