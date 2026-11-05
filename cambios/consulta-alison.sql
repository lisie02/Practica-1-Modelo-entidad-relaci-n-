-- =====================================================================
--  Ejercicio 8.3. Consulta que solo es posible después del cambio
--
--  Obras con riesgo de terminar tarde según el modelo, aunque hoy todavía
--  no tengan retraso, con su fecha de término estimada y la versión del
--  modelo que hizo la predicción.
--  Antes del cambio no existen prediccion_retraso ni modelo_retraso.
-- =====================================================================

SELECT o.obra_id,
       o.nombre_obra,
       f.avance_fisico_acumulado      AS avance_fisico,
       f.dias_retraso                 AS retraso_actual,
       p.probabilidad_retraso         AS prob_retraso,
       p.nivel_riesgo,
       o.fecha_final                  AS fecha_planeada,
       p.fecha_final_estimada         AS fecha_estimada,
       'v' || m.version || ' (' || m.algoritmo || ')' AS modelo,
       to_char(p.generado_en, 'YYYY-MM-DD HH24:MI') AS generado_en
FROM warehouse.prediccion_retraso p
JOIN warehouse.modelo_retraso     m ON m.modelo_key = p.modelo_key
JOIN warehouse.fact_obra_mensual  f ON f.tiempo_key = p.tiempo_key AND f.obra_key = p.obra_key
JOIN warehouse.dim_obra           o ON o.obra_key   = p.obra_key
WHERE p.nivel_riesgo IN ('Alto', 'Medio')
ORDER BY p.probabilidad_retraso DESC;
