-- =====================================================================
-- Consulta demostrativa del cambio del Issue #3.
-- Ejecutar DESPUES de cambio-lisie02.sql, en la base asignada.
-- Inserta un modelo y una prediccion DEMOSTRATIVOS dentro de una
-- transaccion, presenta una fila de resultado y luego hace ROLLBACK.
-- Los valores 0.6500, MEDIO y 30 dias NO son una prediccion real ni
-- proceden de un modelo entrenado; solo demuestran la estructura.
-- =====================================================================

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM warehouse.fact_obra_mensual) THEN
        RAISE EXCEPTION 'No hay filas en warehouse.fact_obra_mensual. Carga la base de demostracion del proyecto asignado antes de probar la consulta.';
    END IF;
END;
$$;

WITH modelo AS (
    INSERT INTO warehouse.modelo_ia
        (nombre, version, fecha_entrenamiento, metricas_evaluacion)
    VALUES
        ('Modelo demostrativo de prediccion de retrasos', 'DEMO-0.1', NULL,
         '{"estado":"DEMO","modelo_entrenado":false}'::jsonb)
    ON CONFLICT (nombre, version)
    DO UPDATE SET nombre = EXCLUDED.nombre
    RETURNING id_modelo, version
), hecho AS (
    SELECT f.tiempo_key, f.obra_key
    FROM warehouse.fact_obra_mensual f
    ORDER BY f.tiempo_key DESC, f.obra_key
    LIMIT 1
), prediccion AS (
    INSERT INTO warehouse.prediccion_riesgo
        (tiempo_key, obra_key, id_modelo, version_modelo,
         fecha_generacion, probabilidad_retraso, nivel_riesgo,
         dias_retraso_estimados, factores_relevantes)
    SELECT
        h.tiempo_key,
        h.obra_key,
        m.id_modelo,
        m.version,
        NOW(),
        0.6500,
        'MEDIO',
        30,
        jsonb_build_object(
            'tipo', 'demostracion',
            'es_prediccion_real', false,
            'nota', 'Valores ilustrativos; no proceden de un modelo entrenado'
        )
    FROM hecho h
    CROSS JOIN modelo m
    RETURNING *
)
SELECT
    p.id_prediccion,
    t.fecha AS fecha_periodo_evaluado,
    o.obra_id,
    o.nombre_obra,
    p.fecha_generacion,
    p.version_modelo,
    p.probabilidad_retraso,
    p.nivel_riesgo,
    p.dias_retraso_estimados,
    p.factores_relevantes
FROM prediccion p
JOIN warehouse.dim_tiempo t ON t.tiempo_key = p.tiempo_key
JOIN warehouse.dim_obra o ON o.obra_key = p.obra_key;

-- Se revierte la fila de demostracion y el modelo de prueba.
ROLLBACK;
