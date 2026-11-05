-- =====================================================================
--  Ejercicio 8. Cambio de esquema: detección de anomalías con
--  aprendizaje automático (Isolation Forest) sobre fact_obra_mensual
--
--  Proyecto asignado: PublicMunicipalWorks_DWH (Obras Públicas)
--  Autora: Rivera Munguia Ameyalli
--
--  Ejecutar sobre una COPIA de la base del proyecto asignado:
--      CREATE DATABASE obras_copia TEMPLATE obras_publicas;
--      psql -U obras -d obras_copia -f cambio-usuario.sql
--
--  El cambio solo agrega tablas; no modifica ni borra datos existentes.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. Versiones del modelo (regla 1: entidad fuerte)
--    Cada entrenamiento del modelo es una versión distinta. Guardar sus
--    hiperparámetros permite explicar después por qué una obra se marcó.
-- ---------------------------------------------------------------------
CREATE TABLE warehouse.modelo_ml (
    modelo_key        SERIAL,
    nombre            VARCHAR(100) NOT NULL,
    version           VARCHAR(20)  NOT NULL,
    algoritmo         VARCHAR(50)  NOT NULL,
    hiperparametros   JSONB        NOT NULL DEFAULT '{}'::JSONB,
    variables_entrada TEXT[]       NOT NULL,
    fecha_entrenamiento TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    activo            BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_modelo_ml PRIMARY KEY (modelo_key),
    CONSTRAINT uq_modelo_version UNIQUE (nombre, version)
);

-- ---------------------------------------------------------------------
-- 2. Resultado del modelo (regla 4: dos relaciones 1:N)
--    fact_obra_mensual (1) — (N) prediccion_anomalia
--    modelo_ml         (1) — (N) prediccion_anomalia
--    Un mismo hecho puede evaluarse con varias versiones del modelo, por
--    eso el resultado va en una tabla aparte y no como columna del hecho.
-- ---------------------------------------------------------------------
CREATE TABLE warehouse.prediccion_anomalia (
    prediccion_key    BIGSERIAL,
    -- Referencia al hecho que califica (PK compuesta de fact_obra_mensual)
    tiempo_key        INTEGER      NOT NULL,
    obra_key          BIGINT       NOT NULL,
    -- Versión del modelo que generó el resultado
    modelo_key        INTEGER      NOT NULL,
    -- Lo que produce el modelo
    puntaje_anomalia  NUMERIC(6,5) NOT NULL,
    es_anomalia       BOOLEAN      NOT NULL,
    -- Marca de tiempo de la predicción
    generado_en       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT pk_prediccion_anomalia PRIMARY KEY (prediccion_key),
    CONSTRAINT ck_puntaje_rango CHECK (puntaje_anomalia BETWEEN 0 AND 1),
    -- Un hecho se evalúa una sola vez por versión del modelo
    CONSTRAINT uq_prediccion_hecho_modelo UNIQUE (tiempo_key, obra_key, modelo_key),
    CONSTRAINT fk_prediccion_hecho FOREIGN KEY (tiempo_key, obra_key)
        REFERENCES warehouse.fact_obra_mensual (tiempo_key, obra_key)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prediccion_modelo FOREIGN KEY (modelo_key)
        REFERENCES warehouse.modelo_ml (modelo_key)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_prediccion_anomalias
    ON warehouse.prediccion_anomalia (modelo_key, es_anomalia)
    WHERE es_anomalia = TRUE;

COMMIT;
