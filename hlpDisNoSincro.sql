call prControlCierreTransferenciaInicioDef(0);
SELECT w.cPatente
     , DATE_FORMAT(w.dProximoCierreIni, '%d/%m/%Y')    dInicio
     , DATE_FORMAT(w.dProximoCierreFin, '%d/%m/%Y')    dFin
     , w.nDiasNoSincro
     , u.cEmail, u.cNombre                                              cNombre
                    /*
                     * Fecha : 29/01/2018
                     * Autor: A.GALAZ
                     * Motivo: Se deja de utilizar la tabla tInicioTransferencia, porque distorsiona
                     * La fecha real del último viaje o control file.
                     *
                     * + " , GREATEST( IFNULL(DATE( w.tUltTransferencia), '0000-00-00')
                     * + " , IFNULL(DATE( w.tUltViaje ), '0000-00-00')
                     * + " , IFNULL(DATE( w.tUltControl ), '0000-00-00')) dSincro
                     */
     , GREATEST( IFNULL(DATE( w.tUltViaje        ), '0000-00-00')
               , IFNULL(DATE( w.tUltControl      ), '0000-00-00'))      dSincro
 FROM  wMemoryCierreTransf w
       JOIN tUsuario u ON u.pUsuario = w.fUsuarioTitular
 WHERE 1=1 -- nDiasAlCierreAnt = ?
 AND   nDiasNoSincro >= 0
 AND   w.cPoliza is not null
 AND   w.bVigente = '1';
 
 SELECT	c.vehicle_id, w.pVehiculo, max(t.from_date) + INTERVAL -3 hour
FROM 	snapcar.clients c 
			JOIN		snapcar.trips		t on t.client_id = c.id
             LEFT JOIN	wMemoryCierreTransf	w on w.pVehiculo = c.vehicle_id
			GROUP BY c.vehicle_id, w.pVehiculo;

SELECT	c.vehicle_id, w.pVehiculo, max(f.event_date) + INTERVAL -3 hour
	FROM 	snapcar.clients c 
			JOIN		snapcar.control_files	f ON f.client_id = c.id            
			LEFT JOIN	wMemoryCierreTransf		w ON w.pVehiculo = c.vehicle_id
	GROUP BY c.vehicle_id, w.pVehiculo;
    
select fnNow(), cPatente, pVehiculo, dProximoCierreIni,LEAST( DATE(fnNow()), dProximoCierreFin ), DATE('2018-02-28')
from wMemoryCierreTransf
where pVehiculo=203;
    SET		nDiasNoSincro = DATEDIFF( LEAST( DATE(fnNow()), dProximoCierreIni )
/*    
	Fecha : 29/01/2018
	Autor: A.GALAZ
	Motivo: Se deja de utilizar la tabla tInicioTransferencia, porque distorsiona
			La fecha real del último viaje o control file.
*/    
--                            , GREATEST( IFNULL(DATE( tUltTransferencia), '0000-00-00')
                              , GREATEST( IFNULL(DATE( tUltViaje        ), '0000-00-00')
                                        , IFNULL(DATE( tUltControl      ), '0000-00-00')) )    