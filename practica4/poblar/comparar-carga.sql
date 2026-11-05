-- Comparacion de carga: COPY frente a INSERT individual.
-- Todas las operaciones se realizan en tablas temporales.

BEGIN;

CREATE TEMP TABLE tmp_copy (
    material TEXT,
    energia_mj NUMERIC(12,2),
    huella_carbono_kg_co2e NUMERIC(12,6),
    acidificacion_mol_h_e NUMERIC,
    eutrofizacion_kg_n_e NUMERIC
);

CREATE TEMP TABLE tmp_insert (
    material TEXT,
    energia_mj NUMERIC(12,2),
    huella_carbono_kg_co2e NUMERIC(12,6),
    acidificacion_mol_h_e NUMERIC,
    eutrofizacion_kg_n_e NUMERIC
);

\echo 'METODO 1: CARGA MASIVA CON COPY'
\timing on
\copy tmp_copy FROM '/tmp/envases_355ml.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\timing off

SELECT 'COPY' AS metodo, COUNT(*) AS filas_cargadas
FROM tmp_copy;

\echo 'METODO 2: INSERT INDIVIDUAL POR RENGLON'
\timing on

INSERT INTO tmp_insert VALUES
('PET', 1.8, 0.095, 0.017, 0.000012);

INSERT INTO tmp_insert VALUES
('Vidrio', 7.6, 0.813, 0.172, 0.000240);

INSERT INTO tmp_insert VALUES
('Aluminio', 5.1, 0.301, 0.078, 0.000036);

\timing off

SELECT 'INSERT individual' AS metodo, COUNT(*) AS filas_cargadas
FROM tmp_insert;

ROLLBACK;
