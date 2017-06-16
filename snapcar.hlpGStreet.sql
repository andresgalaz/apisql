select g.id, g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country, g.display_name
from snapcar.g_streets g
where g.id = 3657; -- g.city not like 'Buenos%'

select g.id, g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country, g.display_name,
	   snapcar.fnNombreCalle( 'C', g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country ) cCalleCorta
--	   snapcar.fnNombreCalle( 'L', g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country ) cCalleLarga
from snapcar.g_streets g
where g.id = 3657; -- g.city not like 'Buenos%'
-- limit 500, 600;
