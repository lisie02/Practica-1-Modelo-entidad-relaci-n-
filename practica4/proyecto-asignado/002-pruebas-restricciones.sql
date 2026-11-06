-- Practica 4 - Ejercicio 1.7
-- Pruebas de las tres restricciones adicionales.
-- EJECUTAR EXCLUSIVAMENTE EN obras_publicas_pruebas.
-- Todos los cambios se revierten mediante ROLLBACK.

DO $$
BEGIN
    IF current_database() <> 'obras_publicas_pruebas' THEN
        RAISE EXCEPTION
            'Prueba detenida: esta operacion solo puede ejecutarse en obras_publicas_pruebas.';
    END IF;
END;
$$;

BEGIN;

-- PRUEBA 1. Rechazar presupuesto negativo.
DO $$
DECLARE
    v_id TEXT;
    v_mensaje TEXT;
BEGIN
    SELECT id_presupuesto INTO v_id
    FROM public.presupuesto_obra
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay presupuestos para realizar la prueba.';
    END IF;

    BEGIN
        UPDATE public.presupuesto_obra
        SET presupuesto_total = -1
        WHERE id_presupuesto = v_id;

        RAISE EXCEPTION 'ERROR: se permitio un presupuesto negativo.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 1 CORRECTA: %', v_mensaje;
    END;
END;
$$;

-- PRUEBA 2. Rechazar costo negativo.
DO $$
DECLARE
    v_id TEXT;
    v_mensaje TEXT;
BEGIN
    SELECT id_gasto INTO v_id
    FROM public.costos
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay costos para realizar la prueba.';
    END IF;

    BEGIN
        UPDATE public.costos
        SET costo = -1
        WHERE id_gasto = v_id;

        RAISE EXCEPTION 'ERROR: se permitio un costo negativo.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 2 CORRECTA: %', v_mensaje;
    END;
END;
$$;

-- PRUEBA 3. Rechazar avance fisico superior a 100.
DO $$
DECLARE
    v_tiempo INTEGER;
    v_obra BIGINT;
    v_mensaje TEXT;
BEGIN
    SELECT tiempo_key, obra_key
    INTO v_tiempo, v_obra
    FROM warehouse.fact_obra_mensual
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay snapshots mensuales para realizar la prueba.';
    END IF;

    BEGIN
        UPDATE warehouse.fact_obra_mensual
        SET avance_fisico_acumulado = 101
        WHERE tiempo_key = v_tiempo
          AND obra_key = v_obra;

        RAISE EXCEPTION 'ERROR: se permitio avance fisico superior a 100.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 3 CORRECTA: %', v_mensaje;
    END;
END;
$$;

-- PRUEBA 4. Rechazar avance presupuestario negativo.
DO $$
DECLARE
    v_tiempo INTEGER;
    v_obra BIGINT;
    v_mensaje TEXT;
BEGIN
    SELECT tiempo_key, obra_key
    INTO v_tiempo, v_obra
    FROM warehouse.fact_obra_mensual
    LIMIT 1;

    BEGIN
        UPDATE warehouse.fact_obra_mensual
        SET avance_presup_acumulado = -1
        WHERE tiempo_key = v_tiempo
          AND obra_key = v_obra;

        RAISE EXCEPTION 'ERROR: se permitio avance presupuestario negativo.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 4 CORRECTA: %', v_mensaje;
    END;
END;
$$;

ROLLBACK;

\echo 'FIN: cuatro pruebas ejecutadas. Los cambios fueron revertidos.'
