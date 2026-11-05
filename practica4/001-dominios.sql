-- Practica 4 - Ejercicio 1.2
-- Migracion 001: restricciones de dominio de EcoData
-- Gestor: PostgreSQL

BEGIN;

-- 1. Los nombres de los catalogos no pueden estar vacios.
ALTER TABLE categoria
ADD CONSTRAINT chk_categoria_nombre_no_vacio
CHECK (btrim(nombre) <> '');

ALTER TABLE pais
ADD CONSTRAINT chk_pais_nombre_no_vacio
CHECK (btrim(nombre) <> '');

ALTER TABLE material
ADD CONSTRAINT chk_material_nombre_no_vacio
CHECK (btrim(nombre) <> '');

ALTER TABLE fuente
ADD CONSTRAINT chk_fuente_nombre_no_vacio
CHECK (btrim(nombre) <> '');

ALTER TABLE producto
ADD CONSTRAINT chk_producto_nombre_no_vacio
CHECK (btrim(nombre) <> '');

-- 2. Los precios no pueden ser negativos.
ALTER TABLE producto
ADD CONSTRAINT chk_producto_precio_no_negativo
CHECK (precio_aproximado >= 0);

-- 3. Los indicadores ambientales no pueden ser negativos.
ALTER TABLE impacto_ambiental
ADD CONSTRAINT chk_impacto_agua_no_negativo
CHECK (consumo_agua >= 0);

ALTER TABLE impacto_ambiental
ADD CONSTRAINT chk_impacto_energia_no_negativo
CHECK (consumo_energia >= 0);

ALTER TABLE impacto_ambiental
ADD CONSTRAINT chk_impacto_co2_no_negativo
CHECK (emisiones_co2 >= 0);

ALTER TABLE impacto_ambiental
ADD CONSTRAINT chk_impacto_residuos_no_negativo
CHECK (residuos_generados >= 0);

-- 4. El nivel de impacto debe utilizar una etiqueta reconocida.
ALTER TABLE impacto_ambiental
ADD CONSTRAINT chk_impacto_nivel_valido
CHECK (
    nivel_impacto IN (
        'Bajo (caso nacional)',
        'Medio (caso nacional)',
        'Alto (caso nacional)'
    )
);

-- 5. Las cantidades de los subtipos no pueden ser negativas.
ALTER TABLE producto_reutilizable
ADD CONSTRAINT chk_reutilizaciones_no_negativas
CHECK (numero_reutilizaciones >= 0);

ALTER TABLE producto_desechable
ADD CONSTRAINT chk_descomposicion_no_negativa
CHECK (tiempo_descomposicion_anios >= 0);

COMMIT;
