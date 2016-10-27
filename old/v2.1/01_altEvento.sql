ALTER TABLE tEvento
 ADD tModif TIMESTAMP not null default '0000-00-00 00:00:00';
update tEvento set tEvento.tModif = '2016-09-01 00:00:00';