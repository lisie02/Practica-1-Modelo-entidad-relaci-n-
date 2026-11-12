-- Practica 5 - Ejercicio 2.5
-- Verificacion de integridad referencial del almacen asignado.
-- Solo consultas de lectura. No modifica el almacen.

-- 1. Inventario de claves foraneas de las tablas principales.
SELECT
    conrelid::regclass AS tabla,
    conname AS restriccion,
    pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE contype = 'f'
  AND connamespace = 'warehouse'::regnamespace
  AND conrelid IN (
      'warehouse.fact_eventos_auditoria'::regclass,
      'warehouse.fact_obra_mensual'::regclass,
      'warehouse.prediccion_riesgo'::regclass
  )
ORDER BY tabla, conname;

-- 2. Referencias huerfanas: hecho de auditoria.

SELECT 'Eventos -> Tiempo' AS relacion, COUNT(*) AS huerfanos
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_tiempo d ON d.tiempo_key = f.tiempo_key
WHERE f.tiempo_key IS NOT NULL AND d.tiempo_key IS NULL

UNION ALL
SELECT 'Eventos -> Tipo evento', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_tipo_evento d ON d.tipo_evento_key = f.tipo_evento_key
WHERE f.tipo_evento_key IS NOT NULL AND d.tipo_evento_key IS NULL

UNION ALL
SELECT 'Eventos -> Obra', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_obra d ON d.obra_key = f.obra_key
WHERE f.obra_key IS NOT NULL AND d.obra_key IS NULL

UNION ALL
SELECT 'Eventos -> Region', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_region d ON d.region_key = f.region_key
WHERE f.region_key IS NOT NULL AND d.region_key IS NULL

UNION ALL
SELECT 'Eventos -> Personal', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_personal d ON d.personal_key = f.personal_key
WHERE f.personal_key IS NOT NULL AND d.personal_key IS NULL

UNION ALL
SELECT 'Eventos -> Constructora', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_constructora d ON d.constructora_key = f.constructora_key
WHERE f.constructora_key IS NOT NULL AND d.constructora_key IS NULL

UNION ALL
SELECT 'Eventos -> Fuente', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_fuente d ON d.fuente_key = f.fuente_key
WHERE f.fuente_key IS NOT NULL AND d.fuente_key IS NULL

UNION ALL
SELECT 'Eventos -> Presupuesto', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_presupuesto d ON d.presupuesto_key = f.presupuesto_key
WHERE f.presupuesto_key IS NOT NULL AND d.presupuesto_key IS NULL

UNION ALL
SELECT 'Eventos -> Poblador', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_poblador d ON d.poblador_key = f.poblador_key
WHERE f.poblador_key IS NOT NULL AND d.poblador_key IS NULL

UNION ALL
SELECT 'Eventos -> Propuesta', COUNT(*)
FROM warehouse.fact_eventos_auditoria f
LEFT JOIN warehouse.dim_propuesta d ON d.propuesta_key = f.propuesta_key
WHERE f.propuesta_key IS NOT NULL AND d.propuesta_key IS NULL

UNION ALL
SELECT 'Hechos mensuales -> Obra', COUNT(*)
FROM warehouse.fact_obra_mensual f
LEFT JOIN warehouse.dim_obra d ON d.obra_key = f.obra_key
WHERE f.obra_key IS NOT NULL AND d.obra_key IS NULL

UNION ALL
SELECT 'Hechos mensuales -> Tiempo', COUNT(*)
FROM warehouse.fact_obra_mensual f
LEFT JOIN warehouse.dim_tiempo d ON d.tiempo_key = f.tiempo_key
WHERE f.tiempo_key IS NOT NULL AND d.tiempo_key IS NULL
ORDER BY relacion;

-- 3. Verificacion de claves primarias compuestas.

SELECT
    'fact_eventos_auditoria' AS tabla,
    COUNT(*) AS grupos_duplicados
FROM (
    SELECT tiempo_key, evento_key
    FROM warehouse.fact_eventos_auditoria
    GROUP BY tiempo_key, evento_key
    HAVING COUNT(*) > 1
) duplicados

UNION ALL

SELECT
    'fact_obra_mensual',
    COUNT(*)
FROM (
    SELECT tiempo_key, obra_key
    FROM warehouse.fact_obra_mensual
    GROUP BY tiempo_key, obra_key
    HAVING COUNT(*) > 1
) duplicados;

-- 4. Conteo de claves foraneas declaradas.

SELECT
    conrelid::regclass AS tabla,
    COUNT(*) AS claves_foraneas
FROM pg_constraint
WHERE contype = 'f'
  AND connamespace = 'warehouse'::regnamespace
  AND conrelid IN (
      'warehouse.fact_eventos_auditoria'::regclass,
      'warehouse.fact_obra_mensual'::regclass,
      'warehouse.prediccion_riesgo'::regclass
  )
GROUP BY conrelid
ORDER BY tabla;

\echo 'FIN: verificacion del almacen completada.'
