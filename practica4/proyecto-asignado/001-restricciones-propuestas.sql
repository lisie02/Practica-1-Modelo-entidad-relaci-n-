-- Practica 4 - Ejercicio 1.7
-- Restricciones adicionales para el proyecto asignado.
-- IMPORTANTE: ejecutar exclusivamente en obras_publicas_pruebas.

BEGIN;

-- Regla 1. El presupuesto de una obra no puede ser negativo.
ALTER TABLE public.presupuesto_obra
ADD CONSTRAINT chk_presupuesto_total_no_negativo
CHECK (presupuesto_total >= 0);

-- Regla 2. Un costo registrado no puede ser negativo.
ALTER TABLE public.costos
ADD CONSTRAINT chk_costo_no_negativo
CHECK (costo >= 0);

-- Regla 3. Los avances acumulados deben estar entre 0 y 100.
ALTER TABLE warehouse.fact_obra_mensual
ADD CONSTRAINT chk_avances_mensuales_rango
CHECK (
    (avance_fisico_acumulado IS NULL
     OR avance_fisico_acumulado BETWEEN 0 AND 100)
    AND
    (avance_presup_acumulado IS NULL
     OR avance_presup_acumulado BETWEEN 0 AND 100)
);

COMMIT;
