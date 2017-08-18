
call prFacturador(null);
select 'Real', v.cPatente, v.dIniVigencia, u.cNombre, u.cEmail
        , w.nScore,w.nKms,w.nKmsPond
        , w.nDescuentoKM,w.nDescuentoSinUso,w.nDescuentoPunta
        , w.nDescuentoKM+w.nDescuentoSinUso+w.nDescuentoPunta nDescuentoSinPond
        , w.nDescuento
        , w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion
from wMemoryScoreVehiculo w
		left join tVehiculo v on v.pVehiculo = w.pVehiculo
        left join tUsuario u on u.pUsuario = v.fUsuarioTitular
union all
select 'Sin Multa', v.cPatente, v.dIniVigencia, u.cNombre, u.cEmail
        , w.nScore,w.nKms,w.nKmsPond
        , w.nDescuentoKM,w.nDescuentoSinUso,w.nDescuentoPunta
        , w.nDescuentoKM+w.nDescuentoSinUso+w.nDescuentoPunta nDescuentoSinPond
        , w.nDescuento
        , w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion
from wMemoryScoreVehiculoSinMulta w
		left join tVehiculo v on v.pVehiculo = w.pVehiculo
        left join tUsuario u on u.pUsuario = v.fUsuarioTitular;
-- where v.dIniVigencia <= w.dInicio;

SELECT	v.pVehiculo				, v.cPatente				, v.cIdDispositivo			, v.bVigente				,
		v.fTpDispositivo		, v.fCuenta					, v.fUsuarioTitular			, v.tModif					,
		v.dIniVigencia			,
		score.fnPeriodoActual( v.dIniVigencia, -1 ) dIniCierre,
		score.fnPeriodoActual( v.dIniVigencia, 0 ) dFinCierre
FROM	score.tVehiculo v
WHERE	v.fTpDispositivo = 3
AND		v.cIdDispositivo is not null
AND		v.bVigente in ('1');
