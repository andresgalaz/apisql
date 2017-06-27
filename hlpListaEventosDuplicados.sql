select e.nIdViaje, e.fTpEvento, e.tEvento, count(*) 
from tEvento e 
-- where e.nIdViaje=3031
group by e.nIdViaje, e.fTpEvento, e.tEvento
having count(*) > 1;