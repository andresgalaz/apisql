DROP VIEW IF EXISTS vScoreMes;
CREATE VIEW vScoreMes AS
select s.pScoreMes		   , s.fCuenta			 , s.dPeriodo		   , s.nSumaFrenada
	 , s.nSumaAceleracion  , s.nSumaVelocidad	 , s.nKms, s.nFrenada  , s.nAceleracion
	 , s.nVelocidad		   , s.nScore			 , s.nDescuento		   , cu.pUsuario fUsuario
	 , c.fUsuarioTitular   , s.fVehiculo		 , v.cPatente
from   tScoreMes s 
	   inner join tCuentaUsuario cu on cu.pCuenta  = s.fCuenta
	   inner join tCuenta		 c  on c.pCuenta   = s.fCuenta
	   inner join tVehiculo		 v  on v.pVehiculo = s.fVehiculo
