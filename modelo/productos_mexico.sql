-- ============================================================
-- EcoData: productos y datos de impacto ambiental
-- Modelos comparativos de envases de refresco de 355 ml.
--
-- Fuente: Cabriales Gomez et al. (2024).
-- Caso de estudio I: analisis nacional.
--
-- Energia: MJ.
-- Emisiones: kg CO2e.
--
-- El esquema no tiene columnas para las unidades.
-- Consumo de agua y residuos se dejan NULL porque la tabla
-- utilizada no proporciona esos valores para estos registros.
--
-- Los niveles Bajo, Medio y Alto son una clasificacion relativa
-- entre los tres envases del caso nacional, no una escala
-- universal de impacto ambiental.
--
-- No se asigna pais de fabricacion porque la fuente utilizada
-- no confirma el lugar de fabricacion de cada envase.
--
-- El script evita insertar productos, relaciones e impactos
-- que ya existan.
-- ============================================================

BEGIN;


-- ============================================================
-- 1. INSERTAR LOS PRODUCTOS
-- ============================================================

-- 1.1 Botella de PET de 355 ml.

INSERT INTO producto (
    nombre,
    marca,
    precio_aproximado,
    vida_util,
    id_categoria
)
SELECT
    'Botella PET para refresco de 355 ml',
    'Coca-Cola',
    NULL,
    NULL,
    c.id_categoria
FROM categoria c
WHERE c.nombre = 'Envases para bebidas'
  AND NOT EXISTS (
      SELECT 1
      FROM producto p
      WHERE p.nombre = 'Botella PET para refresco de 355 ml'
  );


-- 1.2 Envase de vidrio de 355 ml.

INSERT INTO producto (
    nombre,
    marca,
    precio_aproximado,
    vida_util,
    id_categoria
)
SELECT
    'Envase de vidrio para refresco de 355 ml',
    'Coca-Cola',
    NULL,
    NULL,
    c.id_categoria
FROM categoria c
WHERE c.nombre = 'Envases para bebidas'
  AND NOT EXISTS (
      SELECT 1
      FROM producto p
      WHERE p.nombre = 'Envase de vidrio para refresco de 355 ml'
  );


-- 1.3 Lata de aluminio de 355 ml.

INSERT INTO producto (
    nombre,
    marca,
    precio_aproximado,
    vida_util,
    id_categoria
)
SELECT
    'Lata de aluminio para refresco de 355 ml',
    'Coca-Cola',
    NULL,
    NULL,
    c.id_categoria
FROM categoria c
WHERE c.nombre = 'Envases para bebidas'
  AND NOT EXISTS (
      SELECT 1
      FROM producto p
      WHERE p.nombre = 'Lata de aluminio para refresco de 355 ml'
  );


-- ============================================================
-- 2. RELACIONAR CADA PRODUCTO CON SU MATERIAL PRINCIPAL
-- ============================================================

-- 2.1 Botella de PET.

INSERT INTO producto_material (
    id_producto,
    id_material
)
SELECT
    p.id_producto,
    m.id_material
FROM producto p
CROSS JOIN material m
WHERE p.nombre = 'Botella PET para refresco de 355 ml'
  AND m.nombre = 'PET'
  AND NOT EXISTS (
      SELECT 1
      FROM producto_material pm
      WHERE pm.id_producto = p.id_producto
        AND pm.id_material = m.id_material
  );


-- 2.2 Envase de vidrio.

INSERT INTO producto_material (
    id_producto,
    id_material
)
SELECT
    p.id_producto,
    m.id_material
FROM producto p
CROSS JOIN material m
WHERE p.nombre = 'Envase de vidrio para refresco de 355 ml'
  AND m.nombre = 'Vidrio'
  AND NOT EXISTS (
      SELECT 1
      FROM producto_material pm
      WHERE pm.id_producto = p.id_producto
        AND pm.id_material = m.id_material
  );


-- 2.3 Lata de aluminio.

INSERT INTO producto_material (
    id_producto,
    id_material
)
SELECT
    p.id_producto,
    m.id_material
FROM producto p
CROSS JOIN material m
WHERE p.nombre = 'Lata de aluminio para refresco de 355 ml'
  AND m.nombre = 'Aluminio'
  AND NOT EXISTS (
      SELECT 1
      FROM producto_material pm
      WHERE pm.id_producto = p.id_producto
        AND pm.id_material = m.id_material
  );


-- ============================================================
-- 3. REGISTRAR LOS IMPACTOS AMBIENTALES
-- Fuente: UANL - estudio de sustentabilidad de materiales
-- para el envasado de refrescos, caso de estudio I.
-- ============================================================

-- 3.1 PET:
-- Energia: 1.8 MJ.
-- Emisiones: 0.095 kg CO2e.
-- Clasificacion relativa: Bajo.

INSERT INTO impacto_ambiental (
    id_producto,
    id_fuente,
    consumo_energia,
    emisiones_co2,
    nivel_impacto,
    fecha_dato
)
SELECT
    p.id_producto,
    f.id_fuente,
    1.8,
    0.095,
    'Bajo (caso nacional)',
    NULL
FROM producto p
CROSS JOIN fuente f
WHERE p.nombre = 'Botella PET para refresco de 355 ml'
  AND f.nombre =
      'UANL - Sustentabilidad de materiales para envasado de refrescos'
  AND NOT EXISTS (
      SELECT 1
      FROM impacto_ambiental ia
      WHERE ia.id_producto = p.id_producto
        AND ia.id_fuente = f.id_fuente
  );


-- 3.2 Vidrio:
-- Energia: 7.6 MJ.
-- Emisiones: 0.813 kg CO2e.
-- Clasificacion relativa: Alto.

INSERT INTO impacto_ambiental (
    id_producto,
    id_fuente,
    consumo_energia,
    emisiones_co2,
    nivel_impacto,
    fecha_dato
)
SELECT
    p.id_producto,
    f.id_fuente,
    7.6,
    0.813,
    'Alto (caso nacional)',
    NULL
FROM producto p
CROSS JOIN fuente f
WHERE p.nombre = 'Envase de vidrio para refresco de 355 ml'
  AND f.nombre =
      'UANL - Sustentabilidad de materiales para envasado de refrescos'
  AND NOT EXISTS (
      SELECT 1
      FROM impacto_ambiental ia
      WHERE ia.id_producto = p.id_producto
        AND ia.id_fuente = f.id_fuente
  );


-- 3.3 Aluminio:
-- Energia: 5.1 MJ.
-- Emisiones: 0.301 kg CO2e.
-- Clasificacion relativa: Medio.

INSERT INTO impacto_ambiental (
    id_producto,
    id_fuente,
    consumo_energia,
    emisiones_co2,
    nivel_impacto,
    fecha_dato
)
SELECT
    p.id_producto,
    f.id_fuente,
    5.1,
    0.301,
    'Medio (caso nacional)',
    NULL
FROM producto p
CROSS JOIN fuente f
WHERE p.nombre = 'Lata de aluminio para refresco de 355 ml'
  AND f.nombre =
      'UANL - Sustentabilidad de materiales para envasado de refrescos'
  AND NOT EXISTS (
      SELECT 1
      FROM impacto_ambiental ia
      WHERE ia.id_producto = p.id_producto
        AND ia.id_fuente = f.id_fuente
  );


-- ============================================================
-- 4. FINALIZAR LA TRANSACCION
-- ============================================================

COMMIT;