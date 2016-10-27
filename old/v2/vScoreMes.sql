DROP VIEW IF EXISTS vScoreMes;
CREATE VIEW vScoreMes AS
select s.pScoreMes			, s.fCuenta			, s.dPeriodo	, s.nSumaFrenada
	 , s.nSumaAceleracion	, s.nSumaVelocidad	, s.nKms		, s.nFrenada
	 , s.nAceleracion		, s.nVelocidad		, s.nScore		, s.nDescuento
	 , uv.pUsuario fUsuario	, uv.fUsuarioTitular, s.fVehiculo	, v.cPatente
from   tScoreMes s
	   inner join tUsuarioVehiculo	uv	on	uv.pVehiculo	= s.fVehiculo
	   inner join tVehiculo			v	on	v.pVehiculo		= s.fVehiculo
