-- delete from trip_observations_g where trip_id in ( 5714,5735,5716,5742,5737,5724,5728,5709,5706,5736,5711,5719,5732,5723,5704,5731,5718,5707,5738,5733,5741,5730,5722 ) and prefix_observation = 'A';
	

drop table if exists score.work_anomalia;
create table score.work_anomalia as
select trip_id, prefix_observation, count(*) cantidad
from snapcar.trip_observations_g
where from_time >= '2018-02-01'
group by trip_id, prefix_observation
order by cantidad desc;

select t.id trip_id,t.from_date, t.to_date, v.cPatente, v.cIdDispositivo, u.cNombre, u.cEmail, a.prefix_observation, a.cantidad
from score.work_anomalia a
	inner join snapcar.trips	t on t.id = a.trip_id
	inner join snapcar.clients	c on c.id = t.client_id
	inner join score.tVehiculo	v on v.pVehiculo = c.vehicle_id
	inner join score.tUsuario	u on u.pUsuario = v.fUsuarioTitular
;    

# trip_id, from_date, to_date, cPatente, cIdDispositivo, cNombre, cEmail, prefix_observation, cantidad
# '126859', '2018-02-10 11:01:34', '2018-02-10 12:55:55', 'JBH851', '0087', 'Ricardo Alberto Sobrero', 'rsobrero@temaiken.org.ar', 'A', '382'
# '121954', '2018-02-14 13:31:00', '2018-02-14 17:38:55', 'AA429CP', '0147', 'MIRIAN SOLEDAD OJEDA SANCHEZ', 'ojeda_mirian.s@hotmail.com', 'A', '285'
# '138749', '2018-02-25 18:29:00', '2018-02-25 18:56:55', 'FAA680', '0227', 'GONZALO PUEBLA', 'gonzalopuebla@icloud.com', 'A', '110'



SELECT * FROM snapcar.trip_details 
where trip_id=126859
-- and event_date between 
-- '2018-02-10 11:01:34' '2018-02-10 12:55:55'
;
SELECT * FROM snapcar.trip_observations_g  o
where o.trip_id = 138749
;

SELECT o.id id_evento, o.prefix_observation, o.from_time, o.to_time
	 , CASE WHEN d.event_date BETWEEN o.from_time AND o.to_time THEN 'DENTRO' ELSE 'FUERA' END 'intervalo_ocurrencia'
     , d.event_date, d.latitude, d.longitude, d.altitude, d.speed_ms, d.virloc_event, d.position_type, d.position_age, d.x, d.y, d.z, d.ignition
     -- o.*, d.*
FROM snapcar.trip_observations_g  o
	INNER JOIN snapcar.trip_details d ON d.trip_id = o.trip_id
									AND d.event_date between from_time - interval 20 SECOND and to_time + interval 20 SECOND
where o.trip_id = 138749 limit 40000
;


