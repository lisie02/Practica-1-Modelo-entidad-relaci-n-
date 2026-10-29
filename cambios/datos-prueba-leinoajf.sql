-- =====================================================================
--  Datos de prueba para el ejercicio 8 (ejecutar DESPUÉS de cambio-usuario.sql)
--
--  Si su copia ya tiene obras y snapshots mensuales cargados, omita la
--  sección A y use las obras existentes.
--
--  Los puntajes de la sección C simulan la salida de un Isolation Forest
--  (sklearn.ensemble.IsolationForest), normalizada a [0, 1]: valores
--  cercanos a 1 indican una combinación de variables poco común.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- A. Datos mínimos del sistema: 1 constructora, 1 región, 1 supervisor
--    y 4 obras. Los disparadores del proyecto llenan las dimensiones.
-- ---------------------------------------------------------------------
INSERT INTO public.constructora (id_constructora, rfc, nombre_const, tipo_ejecutor)
VALUES ('CONST-01', 'CTE010101AB1', 'Constructora Temascaltepec', 'Contrato');

INSERT INTO public.region (id_region, comunidad, barrio, colonia)
VALUES ('REG-01', 'Temascaltepec', 'Centro', NULL);

INSERT INTO public.personal (codigo_personal, nombre, apellido_paterno, rol)
VALUES ('SUP-01', 'Laura', 'Gómez', 'Supervisor');
INSERT INTO public.supervisor (codigo_personal, telefono)
VALUES ('SUP-01', '7161234567');

INSERT INTO public.obra (id_obra, codigo_expediente, nombre_obra, etapa, fecha_inicio,
                         fecha_final, descripcion, beneficiarios, id_constructora,
                         id_region, codigo_supervisor)
VALUES
 ('OBRA-0001', 'EXP-2026-001', 'Pavimentación calle Hidalgo',   3, '2026-02-01', '2026-08-31', 'Pavimento con concreto hidráulico', '1,200 habitantes', 'CONST-01', 'REG-01', 'SUP-01'),
 ('OBRA-0002', 'EXP-2026-002', 'Red de agua potable Barrio Alto', 3, '2026-03-01', '2026-11-30', 'Ampliación de red hidráulica',     '800 habitantes',   'CONST-01', 'REG-01', 'SUP-01'),
 ('OBRA-0003', 'EXP-2026-003', 'Rehabilitación de escuela primaria', 3, '2026-01-15', '2026-06-30', 'Techumbre y sanitarios',      '350 alumnos',      'CONST-01', 'REG-01', 'SUP-01'),
 ('OBRA-0004', 'EXP-2026-004', 'Alumbrado público carretera',   3, '2026-04-01', '2026-10-31', 'Luminarias LED',                    '2,000 habitantes', 'CONST-01', 'REG-01', 'SUP-01');

-- ---------------------------------------------------------------------
-- B. Snapshot mensual de septiembre de 2026 (tabla de hechos existente)
--    OBRA-0003 tiene 80 % pagado con 25 % de avance físico.
-- ---------------------------------------------------------------------
INSERT INTO warehouse.fact_obra_mensual
    (tiempo_key, obra_key, presupuesto_total, costo_acumulado, saldo_presupuesto,
     porcentaje_ejercido, avance_fisico_acumulado, avance_presup_acumulado,
     dias_retraso, informes_registrados, imagenes_evidencia, permisos_obtenidos,
     tiene_retraso, tiene_alertas)
SELECT 20260930, d.obra_key, v.presupuesto, v.costo, v.presupuesto - v.costo,
       ROUND(v.costo / v.presupuesto * 100, 2), v.fisico, v.presup,
       v.retraso, v.informes, v.imagenes, v.permisos, v.retraso > 0, FALSE
FROM (VALUES
  ('OBRA-0001', 2500000.00, 2300000.00, 95, 92,  30, 7, 21, 2),
  ('OBRA-0002', 4100000.00, 2600000.00, 60, 63,   0, 6, 18, 3),
  ('OBRA-0003', 1800000.00, 1450000.00, 25, 80,  92, 2,  1, 1),
  ('OBRA-0004', 3200000.00, 1700000.00, 52, 53,   0, 5, 14, 2)
) AS v(obra_id, presupuesto, costo, fisico, presup, retraso, informes, imagenes, permisos)
JOIN warehouse.dim_obra d ON d.obra_id = v.obra_id AND d.es_actual;

-- ---------------------------------------------------------------------
-- C. Versión del modelo y sus predicciones
-- ---------------------------------------------------------------------
INSERT INTO warehouse.modelo_ml (nombre, version, algoritmo, hiperparametros, variables_entrada)
VALUES ('detector_anomalias_obra', '1.0.0', 'IsolationForest',
        '{"n_estimators": 200, "contamination": 0.05, "random_state": 42}',
        ARRAY['costo_acumulado', 'avance_fisico_acumulado', 'avance_presup_acumulado',
              'dias_retraso', 'informes_registrados', 'imagenes_evidencia']);

INSERT INTO warehouse.prediccion_anomalia (tiempo_key, obra_key, modelo_key, puntaje_anomalia, es_anomalia)
SELECT f.tiempo_key, f.obra_key, m.modelo_key, v.puntaje, v.puntaje >= 0.70
FROM (VALUES ('OBRA-0001', 0.31200), ('OBRA-0002', 0.28400),
             ('OBRA-0003', 0.91700), ('OBRA-0004', 0.26900)) AS v(obra_id, puntaje)
JOIN warehouse.dim_obra d ON d.obra_id = v.obra_id AND d.es_actual
JOIN warehouse.fact_obra_mensual f ON f.obra_key = d.obra_key AND f.tiempo_key = 20260930
CROSS JOIN warehouse.modelo_ml m
WHERE m.nombre = 'detector_anomalias_obra' AND m.version = '1.0.0';

COMMIT;
