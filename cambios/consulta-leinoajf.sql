-- =====================================================================
--  Ejercicio 8.3. Consulta que solo es posible después del cambio
--
--  Obras que el modelo de aprendizaje automático marcó como anómalas,
--  con la versión del modelo que lo decidió y cuándo lo decidió, junto
--  con lo que dicen las reglas fijas de la vista original.
--  Antes del cambio no existen prediccion_anomalia ni modelo_ml.
-- =====================================================================

SELECT o.obra_id,
       o.nombre_obra,
       f.avance_fisico_acumulado        AS avance_fisico,
       f.avance_presup_acumulado        AS avance_pagado,
       p.puntaje_anomalia               AS puntaje_ml,
       p.es_anomalia                    AS anomalia_ml,
       m.algoritmo || ' v' || m.version AS modelo,
       to_char(p.generado_en, 'YYYY-MM-DD HH24:MI') AS generado_en,
       v.es_anomalia                    AS anomalia_reglas
FROM warehouse.prediccion_anomalia p
JOIN warehouse.modelo_ml          m ON m.modelo_key = p.modelo_key
JOIN warehouse.fact_obra_mensual  f ON f.tiempo_key = p.tiempo_key AND f.obra_key = p.obra_key
JOIN warehouse.dim_obra           o ON o.obra_key   = p.obra_key
LEFT JOIN warehouse.v_anomalias_deteccion v
       ON v.tiempo_key = p.tiempo_key AND v.obra_key = p.obra_key
WHERE m.activo
ORDER BY p.puntaje_anomalia DESC;
