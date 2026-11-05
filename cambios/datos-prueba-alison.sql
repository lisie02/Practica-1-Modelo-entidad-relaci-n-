-- =====================================================================
--  Datos de prueba para el ejercicio 8 (ejecutar DESPUÉS de cambio-alison.sql)
--
--  Si su copia ya tiene obras y snapshots mensuales cargados, omita la
--  sección A y use las obras existentes.
--
--  Las predicciones de la sección C simulan la salida de un
--  RandomForestClassifier (probabilidad de terminar tarde) y un
--  RandomForestRegressor (días de retraso estimados), entrenados con el
--  historial mensual de obras ya terminadas.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- A. Datos mínimos del sistema. Los disparadores llenan las dimensiones.
-- ---------------------------------------------------------------------
INSERT INTO public.constructora (id_constructora, rfc, nombre_const, tipo_ejecutor)
VALUES ('CONST-10', 'CSV100512XY3', 'Constructora Sierra Verde', 'Contrato');

INSERT INTO public.region (id_region, comunidad, barrio, colonia)
VALUES ('REG-10', 'San Pedro Tenayac', 'La Loma', NULL);

INSERT INTO public.personal (codigo_personal, nombre, apellido_paterno, rol)
VALUES ('SUP-10', 'Ramiro', 'Ortega', 'Supervisor');
INSERT INTO public.supervisor (codigo_personal, telefono)
VALUES ('SUP-10', '7169876543');

INSERT INTO public.obra (id_obra, codigo_expediente, nombre_obra, etapa, fecha_inicio,
                         fecha_final, descripcion, beneficiarios, id_constructora,
                         id_region, codigo_supervisor)
VALUES
 ('OBRA-1001', 'EXP-2026-101', 'Puente vehicular arroyo La Loma',  3, '2026-03-01', '2026-12-15', 'Puente de concreto de 18 m',   '3,500 habitantes', 'CONST-10', 'REG-10', 'SUP-10'),
 ('OBRA-1002', 'EXP-2026-102', 'Centro de salud comunitario',     3, '2026-02-15', '2026-11-30', 'Construcción de consultorios', '2,100 habitantes', 'CONST-10', 'REG-10', 'SUP-10'),
 ('OBRA-1003', 'EXP-2026-103', 'Drenaje sanitario calle Morelos', 3, '2026-05-01', '2026-10-31', 'Red de drenaje y descargas',   '600 habitantes',   'CONST-10', 'REG-10', 'SUP-10'),
 ('OBRA-1004', 'EXP-2026-104', 'Cancha de usos múltiples',        3, '2026-06-01', '2026-11-15', 'Cancha techada',               '900 habitantes',   'CONST-10', 'REG-10', 'SUP-10');

-- ---------------------------------------------------------------------
-- B. Snapshot mensual de septiembre de 2026 (tabla de hechos existente)
--    Ninguna obra lleva retraso todavía (dias_retraso = 0), pero el
--    puente y el centro de salud avanzan muy lento para el tiempo que
--    les queda.
-- ---------------------------------------------------------------------
INSERT INTO warehouse.fact_obra_mensual
    (tiempo_key, obra_key, presupuesto_total, costo_acumulado, saldo_presupuesto,
     porcentaje_ejercido, avance_fisico_acumulado, avance_presup_acumulado,
     dias_retraso, informes_registrados, imagenes_evidencia, permisos_obtenidos,
     tiene_retraso, tiene_alertas)
SELECT 20260930, d.obra_key, v.presupuesto, v.costo, v.presupuesto - v.costo,
       ROUND(v.costo / v.presupuesto * 100, 2), v.fisico, v.presup,
       0, v.informes, v.imagenes, v.permisos, FALSE, FALSE
FROM (VALUES
  ('OBRA-1001', 6800000.00, 2900000.00, 34, 43, 4,  9, 1),
  ('OBRA-1002', 5200000.00, 2700000.00, 41, 52, 5, 12, 2),
  ('OBRA-1003', 1400000.00, 1250000.00, 88, 89, 4, 16, 2),
  ('OBRA-1004',  950000.00,  420000.00, 46, 44, 3,  8, 1)
) AS v(obra_id, presupuesto, costo, fisico, presup, informes, imagenes, permisos)
JOIN warehouse.dim_obra d ON d.obra_id = v.obra_id AND d.es_actual;

-- ---------------------------------------------------------------------
-- C. Versión del modelo y sus predicciones
-- ---------------------------------------------------------------------
INSERT INTO warehouse.modelo_retraso (version, algoritmo, meses_minimos, exactitud_validacion)
VALUES ('1.0.0', 'RandomForest', 3, 0.8125);

INSERT INTO warehouse.prediccion_retraso
    (tiempo_key, obra_key, modelo_key, probabilidad_retraso, dias_retraso_estimados,
     fecha_final_estimada, nivel_riesgo)
SELECT f.tiempo_key, f.obra_key, m.modelo_key, v.prob, v.dias,
       d.fecha_final + v.dias,
       CASE WHEN v.prob >= 0.70 THEN 'Alto' WHEN v.prob >= 0.40 THEN 'Medio' ELSE 'Bajo' END
FROM (VALUES ('OBRA-1001', 0.8640, 74), ('OBRA-1002', 0.7210, 41),
             ('OBRA-1003', 0.1180,  0), ('OBRA-1004', 0.4350, 12)) AS v(obra_id, prob, dias)
JOIN warehouse.dim_obra d ON d.obra_id = v.obra_id AND d.es_actual
JOIN warehouse.fact_obra_mensual f ON f.obra_key = d.obra_key AND f.tiempo_key = 20260930
CROSS JOIN warehouse.modelo_retraso m
WHERE m.version = '1.0.0';

COMMIT;
