SELECT TIMESTAMPDIFF(SECOND, t.from_date, t.created_at) segundos, t.*
FROM   snapcar.trips t
WHERE  t.distance > 300
AND    t.status <> 'D'
AND TIMESTAMPDIFF(SECOND, t.from_date, t.created_at) > 0
;

-- Crea tabla temporal para el analisis
DROP TABLE IF EXISTS wHorasUsoVehiculo
;
CREATE TABLE wHorasUsoVehiculo as
SELECT SUBSTR(t.from_date,1,10) dia, c.vehicle_id, ROUND(SUM(TIMESTAMPDIFF(SECOND, t.from_date, t.to_date))/3600,2) horas
FROM   snapcar.trips t
       INNER JOIN snapcar.clients c ON c.id = t.client_id
WHERE  t.distance > 300
AND    t.status <> 'D'
AND    c.vehicle_id > 0
GROUP BY SUBSTR(t.from_date,1,10), c.vehicle_id
;

-- Lista cantidad de horas de uso por auto
SELECT dia, count(vehicle_id) cantidad_vehiculos, sum(horas) total_horas, ROUND(sum(horas)  / count(vehicle_id),2) horas_por_vehiculo
FROM wHorasUsoVehiculo
GROUP BY dia
LIMIT 1000
;

-- Crea tabla temporal para el analisis
DROP TABLE IF EXISTS wHorasUsoVehiculo
;
CREATE TABLE wHorasUsoVehiculo as
SELECT ROUND(TIMESTAMPDIFF(SECOND, t.from_date, t.created_at)/3600,2) horas
, ROUND(TIMESTAMPDIFF(SECOND, t.from_date, t.created_at)/3600/24,2) dias
, ROUND(TIMESTAMPDIFF(SECOND, t.from_date, t.created_at)/3600/24/30,2) meses
FROM   snapcar.trips t
       INNER JOIN snapcar.clients c ON c.id = t.client_id
WHERE  t.distance > 300
AND    t.status <> 'D'
AND    c.vehicle_id > 0
AND TIMESTAMPDIFF(SECOND, t.from_date, t.created_at) > 0
;

SELECT *
FROM wHorasUsoVehiculo
WHERE dias > 0
;
-- Lista uso por auto
SELECT 'EN VIAJE' tiempo, COUNT(*) cant_viajes_sync
FROM wHorasUsoVehiculo
WHERE horas < 1
AND dias < 1
AND meses < 1
UNION ALL
SELECT 'DENTRO DEL DIA', COUNT(*)
FROM wHorasUsoVehiculo
WHERE horas >= 1 
AND dias < 1 
AND meses < 1
UNION ALL
SELECT '1 DIA', COUNT(*)
FROM wHorasUsoVehiculo
WHERE dias >= 1 and dias < 2 
AND meses < 1
UNION ALL
SELECT '1 SEMANA', COUNT(*)
FROM wHorasUsoVehiculo
WHERE dias >= 2 AND dias <10
AND meses < 1
UNION ALL
SELECT '1 MES', COUNT(*)
FROM wHorasUsoVehiculo
WHERE meses >= 1 AND meses < 2
UNION ALL
SELECT 'MAS DE 1 MES', COUNT(*)
FROM wHorasUsoVehiculo
WHERE meses >= 2

;
