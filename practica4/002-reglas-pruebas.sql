-- Practica 4 - Ejercicio 1.5
-- Migracion 002: reglas adicionales para pruebas de dominio.

BEGIN;

-- 1. DEFAULT para la fecha de consulta.
ALTER TABLE fuente
ALTER COLUMN fecha_consulta SET DEFAULT CURRENT_DATE;

-- 2. UNIQUE simple: cada material tiene un nombre unico.
ALTER TABLE material
ADD CONSTRAINT uq_material_nombre UNIQUE (nombre);

-- 3. UNIQUE simple: evita registrar la misma URL de fuente.
ALTER TABLE fuente
ADD CONSTRAINT uq_fuente_url UNIQUE (url);

-- 4. UNIQUE compuesta: producto unico dentro de su categoria.
ALTER TABLE producto
ADD CONSTRAINT uq_producto_nombre_categoria
UNIQUE (nombre, id_categoria);

-- 5. CHECK de formato: URL HTTP o HTTPS sin espacios.
ALTER TABLE fuente
ADD CONSTRAINT chk_fuente_url_formato
CHECK (
    url IS NULL
    OR url ~* '^https?://[^[:space:]]+$'
);

-- 6. CHECK entre columnas:
-- Una clasificacion de impacto requiere emisiones registradas.
ALTER TABLE impacto_ambiental
ADD CONSTRAINT chk_nivel_requiere_emisiones
CHECK (
    nivel_impacto IS NULL
    OR emisiones_co2 IS NOT NULL
);

COMMIT;
