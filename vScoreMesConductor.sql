DROP VIEW IF EXISTS vScoreMesConductor;
CREATE VIEW vScoreMesConductor AS
select s.pScoreMesConductor	, s.fVehiculo		, s.dPeriodo	, s.nSumaFrenada
	 , s.nSumaAceleracion	, s.nSumaVelocidad	, s.nKms		, s.nFrenada
	 , s.nAceleracion		, s.nVelocidad		, s.nScore		, v.cPatente
	 , v.fUsuarioTitular	, ut.cNombre	AS cUsuarioTitular
	 , s.fUsuario			, uu.cNombre		AS cUsuario
from   tScoreMesConductor s
	   inner join tVehiculo	v	on	v.pVehiculo		= s.fVehiculo
	   inner join tUsuario	ut	on	ut.pUsuario		= v.fUsuarioTitular
	   inner join tUsuario	uu	on	uu.pUsuario		= s.fUsuario;
