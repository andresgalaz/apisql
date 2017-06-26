select g.id, g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country, g.display_name
from snapcar.g_streets g
where g.id = 3657; -- g.city not like 'Buenos%'

DROP TABLE zz_AGV;

create table zz_AGV as
select g.id, g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country, g.display_name,
	   snapcar.fnNombreCalle( 'C', g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country ) cCalleCorta,
	   snapcar.fnNombreCalle( 'L', g.name, g.street_number, g.town, g.city, g.substate, g.state, g.country ) cCalleLarga
from snapcar.g_streets g
where g.id = 3657; -- g.city not like 'Buenos%'
-- limit 500, 600;

-- Filtra por largo de la direccion
drop table zz_AGV_len;

create table zz_AGV_len as
select max(id) id,length(cCalleCorta) largo from zz_AGV
group by length(cCalleCorta);

insert into zz_AGV_len
select min(id) id,length(cCalleCorta) largo from zz_AGV
group by length(cCalleCorta);


select a.* from zz_AGV a join zz_AGV_len l on l.id = a.id;