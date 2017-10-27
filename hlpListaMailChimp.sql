-- Crea listas para mailChimp
select u.cEmail
, SUBSTRING_INDEX(SUBSTRING_INDEX(u.cNombre, ' ', 1), ' ', -1) AS first_name
, SUBSTRING_INDEX(SUBSTRING_INDEX(u.cNombre, ' ', 3), ' ', -1) AS last_name 
, u.cNombre
, v.cPatente, v.dIniVigencia
, u.tModif tModifUsr, v.tModif tModifVeh, v.cPoliza
 from tUsuario u 
	left join tVehiculo v on v.fUsuarioTitular = u.pUsuario 
 where u.cEmail in (
'fedemrodriguez@outlook.com',
'leodalo@hotmail.com',
'pablogonzalezday@gmail.com',
'oficina.arcon@gmail.com',
'matias.benedetti@gmail.com') 
or u.tModif >= DATE(NOW()) + INTERVAL -3 DAY;
