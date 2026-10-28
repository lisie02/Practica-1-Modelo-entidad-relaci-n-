-- EcoData: modelos de envases de refresco de 355 ml para el caso nacional de Mexico.
-- Fuente de impactos: Cabriales Gomez et al. (2024), Tabla III, Caso de estudio I.
-- Las cifras de energia estan en MJ y las emisiones en kg CO2e, segun la fuente.
-- El esquema actual no guarda unidades ni acidificacion/eutrofizacion en columnas propias.
-- Por eso consumo_agua y residuos_generados se dejan NULL; eutrofizacion NO es consumo de agua.
-- Los niveles Alto/Medio/Bajo son una clasificacion relativa entre estos tres envases en el caso I.
-- Se inserta solo si el producto, relacion o impacto aun no existe, para evitar duplicados al reejecutar.

BEGIN;

-- 1. Productos usados como modelos comparativos en el estudio de Mexico.
INSERT INTO producto (nombre, marca, precio_aproximado, vida_util, id_categoria, id_pais)
SELECT 'Botella PET para refresco de 355 ml', 'Coca-Cola', NULL, NULL, c.id_categoria, pa.id_pais
FROM categoria c CROSS JOIN pais pa
WHERE c.nombre = 'Envases para bebidas'
  AND pa.nombre = U&'M\00e9xico'
  AND NOT EXISTS (
      SELECT 1 FROM producto p WHERE p.nombre = 'Botella PET para refresco de 355 ml'
  );

INSERT INTO producto (nombre, marca, precio_aproximado, vida_util, id_categoria, id_pais)
SELECT 'Envase de vidrio para refresco de 355 ml', 'Coca-Cola', NULL, NULL, c.id_categoria, pa.id_pais
FROM categoria c CROSS JOIN pais pa
WHERE c.nombre = 'Envases para bebidas'
  AND pa.nombre = U&'M\00e9xico'
  AND NOT EXISTS (
      SELECT 1 FROM producto p WHERE p.nombre = 'Envase de vidrio para refresco de 355 ml'
  );

INSERT INTO producto (nombre, marca, precio_aproximado, vida_util, id_categoria, id_pais)
SELECT 'Lata de aluminio para refresco de 355 ml', 'Coca-Cola', NULL, NULL, c.id_categoria, pa.id_pais
FROM categoria c CROSS JOIN pais pa
WHERE c.nombre = 'Envases para bebidas'
  AND pa.nombre = U&'M\00e9xico'
  AND NOT EXISTS (
      SELECT 1 FROM producto p WHERE p.nombre = 'Lata de aluminio para refresco de 355 ml'
  );

-- 2. Relacionar cada producto con su material principal.
INSERT INTO producto_material (id_producto, id_material)
SELECT p.id_producto, m.id_material
FROM producto p CROSS JOIN material m
WHERE p.nombre = 'Botella PET para refresco de 355 ml'
  AND m.nombre = 'PET'
  AND NOT EXISTS (
      SELECT 1 FROM producto_material pm
      WHERE pm.id_producto = p.id_producto AND pm.id_material = m.id_material
  );

INSERT INTO producto_material (id_producto, id_material)
SELECT p.id_producto, m.id_material
FROM producto p CROSS JOIN material m
WHERE p.nombre = 'Envase de vidrio para refresco de 355 ml'
  AND m.nombre = 'Vidrio'
  AND NOT EXISTS (
      SELECT 1 FROM producto_material pm
      WHERE pm.id_producto = p.id_producto AND pm.id_material = m.id_material
  );

INSERT INTO producto_material (id_producto, id_material)
SELECT p.id_producto, m.id_material
FROM producto p CROSS JOIN material m
WHERE p.nombre = 'Lata de aluminio para refresco de 355 ml'
  AND m.nombre = 'Aluminio'
  AND NOT EXISTS (
      SELECT 1 FROM producto_material pm
      WHERE pm.id_producto = p.id_producto AND pm.id_material = m.id_material
  );

-- 3. Impactos del Caso I (analisis nacional) de la Tabla III del articulo UANL.
-- PET: 0.095 kg CO2e; 1.8 MJ.
INSERT INTO impacto_ambiental
    (id_producto, id_fuente, consumo_energia, emisiones_co2, nivel_impacto, fecha_dato)
SELECT p.id_producto, f.id_fuente, 1.8, 0.095, 'Bajo (caso nacional)', NULL
FROM producto p CROSS JOIN fuente f
WHERE p.nombre = 'Botella PET para refresco de 355 ml'
  AND f.nombre = 'UANL - Sustentabilidad de materiales para envasado de refrescos'
  AND NOT EXISTS (
      SELECT 1 FROM impacto_ambiental ia
      WHERE ia.id_producto = p.id_producto AND ia.id_fuente = f.id_fuente
  );

-- Vidrio: 0.813 kg CO2e; 7.6 MJ.
INSERT INTO impacto_ambiental
    (id_producto, id_fuente, consumo_energia, emisiones_co2, nivel_impacto, fecha_dato)
SELECT p.id_producto, f.id_fuente, 7.6, 0.813, 'Alto (caso nacional)', NULL
FROM producto p CROSS JOIN fuente f
WHERE p.nombre = 'Envase de vidrio para refresco de 355 ml'
  AND f.nombre = 'UANL - Sustentabilidad de materiales para envasado de refrescos'
  AND NOT EXISTS (
      SELECT 1 FROM impacto_ambiental ia
      WHERE ia.id_producto = p.id_producto AND ia.id_fuente = f.id_fuente
  );

-- Aluminio: 0.301 kg CO2e; 5.1 MJ.
INSERT INTO impacto_ambiental
    (id_producto, id_fuente, consumo_energia, emisiones_co2, nivel_impacto, fecha_dato)
SELECT p.id_producto, f.id_fuente, 5.1, 0.301, 'Medio (caso nacional)', NULL
FROM producto p CROSS JOIN fuente f
WHERE p.nombre = 'Lata de aluminio para refresco de 355 ml'
  AND f.nombre = 'UANL - Sustentabilidad de materiales para envasado de refrescos'
  AND NOT EXISTS (
      SELECT 1 FROM impacto_ambiental ia
      WHERE ia.id_producto = p.id_producto AND ia.id_fuente = f.id_fuente
  );

COMMIT;
