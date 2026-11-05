-- =====================================================================
--  Ejercicio 8. Cambio de esquema: predicción de retraso de obras
--  con aprendizaje automático (clasificador + regresión)
--
--  Proyecto asignado: PublicMunicipalWorks_DWH (Obras Públicas)
--  Autora: Gutiérrez Cruz Alison
--
--  Ejecutar sobre una COPIA de la base del proyecto asignado:
--      CREATE DATABASE obras_copia_alison TEMPLATE obras_publicas;
--      psql -U obras -d obras_copia_alison -f cambio-alison.sql
--
--  El cambio solo agrega tablas; no modifica ni borra datos existentes.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Versiones del modelo de retraso (regla 1: entidad fuerte)
--    Se registra con qué métrica se validó cada versión, para saber
--    qué tan confiable es antes de usar sus predicciones.
-- ---------------------------------------------------------------------
CREATE TABLE warehouse.modelo_retraso (
    modelo_key           SERIAL,
    version              VARCHAR(20)  NOT NULL,
    algoritmo            VARCHAR(50)  NOT NULL,
    meses_minimos        SMALLINT     NOT NULL,
    exactitud_validacion NUMERIC(5,4),
    fecha_entrenamiento  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_modelo_retraso PRIMARY KEY (modelo_key),
    CONSTRAINT uq_modelo_retraso_version UNIQUE (version),
    CONSTRAINT ck_modelo_meses CHECK (meses_minimos >= 1),
    CONSTRAINT ck_modelo_exactitud CHECK (exactitud_validacion BETWEEN 0 AND 1)
);

-- ---------------------------------------------------------------------
-- 2. Predicción (regla 4: dos relaciones 1:N)
--    fact_obra_mensual (1) — (N) prediccion_retraso
--    modelo_retraso    (1) — (N) prediccion_retraso
--    La predicción se hace con los datos de un mes concreto, por eso
--    califica al hecho mensual y no a la obra en general.
-- ---------------------------------------------------------------------
CREATE TABLE warehouse.prediccion_retraso (
    prediccion_key         BIGSERIAL,
    -- Hecho que califica
    tiempo_key             INTEGER      NOT NULL,
    obra_key               BIGINT       NOT NULL,
    -- Versión del modelo
    modelo_key             INTEGER      NOT NULL,
    -- Lo que produce el modelo
    probabilidad_retraso   NUMERIC(5,4) NOT NULL,
    dias_retraso_estimados INTEGER      NOT NULL,
    fecha_final_estimada   DATE         NOT NULL,
    nivel_riesgo           VARCHAR(10)  NOT NULL,
    -- Marca de tiempo
    generado_en            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_prediccion_retraso PRIMARY KEY (prediccion_key),
    CONSTRAINT ck_retraso_probabilidad CHECK (probabilidad_retraso BETWEEN 0 AND 1),
    CONSTRAINT ck_retraso_dias CHECK (dias_retraso_estimados >= 0),
    CONSTRAINT ck_retraso_nivel CHECK (nivel_riesgo IN ('Bajo', 'Medio', 'Alto')),
    CONSTRAINT uq_retraso_hecho_modelo UNIQUE (tiempo_key, obra_key, modelo_key),
    CONSTRAINT fk_retraso_hecho FOREIGN KEY (tiempo_key, obra_key)
        REFERENCES warehouse.fact_obra_mensual (tiempo_key, obra_key)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_retraso_modelo FOREIGN KEY (modelo_key)
        REFERENCES warehouse.modelo_retraso (modelo_key)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_prediccion_retraso_riesgo
    ON warehouse.prediccion_retraso (nivel_riesgo, probabilidad_retraso DESC);

COMMIT;
