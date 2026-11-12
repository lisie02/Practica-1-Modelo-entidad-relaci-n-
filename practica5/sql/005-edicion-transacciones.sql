-- Practica 5 - Ejercicio 2.4
-- Edicion de valores mediante DML.
-- Ejecutar exclusivamente en ecodata_pruebas.

DO $$
BEGIN
    IF current_database() <> 'ecodata_pruebas' THEN
        RAISE EXCEPTION 'Ejecutar exclusivamente en ecodata_pruebas.';
    END IF;
END;
$$;

-- ==========================================================
-- 1. INSERT que obtiene sus valores de una consulta.
-- ==========================================================

INSERT INTO producto
    (nombre, marca, vida_util, id_categoria, id_pais)
SELECT
    'Botella reutilizable de acero inoxidable 750 ml - prueba',
    'EcoData',
    '5 años',
    c.id_categoria,
    NULL
FROM categoria c
WHERE c.id_categoria = 6
ON CONFLICT (nombre, id_categoria) DO NOTHING
RETURNING id_producto, nombre, id_categoria;

-- 2. INSERT que resuelve una posible duplicidad.
-- Ejecutar dos veces no genera productos duplicados.

INSERT INTO producto
    (nombre, marca, vida_util, id_categoria, id_pais)
SELECT
    'Botella reutilizable de acero inoxidable 750 ml - prueba',
    'EcoData',
    '5 años',
    c.id_categoria,
    NULL
FROM categoria c
WHERE c.id_categoria = 6
ON CONFLICT (nombre, id_categoria) DO NOTHING
RETURNING id_producto, nombre;

-- Asociar el producto de prueba con el material acero inoxidable.

INSERT INTO producto_material (id_producto, id_material)
SELECT p.id_producto, m.id_material
FROM producto p
CROSS JOIN material m
WHERE p.nombre =
    'Botella reutilizable de acero inoxidable 750 ml - prueba'
  AND m.id_material = 5
ON CONFLICT (id_producto, id_material) DO NOTHING
RETURNING id_producto, id_material;

-- ==========================================================
-- 3. UPDATE que depende de otra tabla.
-- La vida util se actualiza a partir de la categoria.
-- ==========================================================

UPDATE producto p
SET vida_util = '5 años'
FROM categoria c
WHERE p.id_categoria = c.id_categoria
  AND c.nombre = 'Productos reutilizables'
  AND p.nombre =
      'Botella reutilizable de acero inoxidable 750 ml - prueba'
RETURNING p.id_producto, p.nombre, c.nombre AS categoria, p.vida_util;

-- ==========================================================
-- 4. UPDATE que clasifica usando CASE.
-- La clasificacion se basa en las emisiones de CO2.
-- ==========================================================

UPDATE impacto_ambiental
SET nivel_impacto =
    CASE
        WHEN emisiones_co2 <= 0.15
            THEN 'Bajo (caso nacional)'
        WHEN emisiones_co2 <= 0.50
            THEN 'Medio (caso nacional)'
        ELSE 'Alto (caso nacional)'
    END
WHERE emisiones_co2 IS NOT NULL
RETURNING id_impacto, emisiones_co2, nivel_impacto;

-- ==========================================================
-- 5. DELETE con subconsulta.
-- Elimina el producto de prueba que utiliza acero inoxidable.
-- CASCADE elimina la asociacion producto-material.
-- ==========================================================

DELETE FROM producto
WHERE nombre =
    'Botella reutilizable de acero inoxidable 750 ml - prueba'
  AND id_producto IN (
      SELECT pm.id_producto
      FROM producto_material pm
      WHERE pm.id_material = 5
  )
RETURNING id_producto, nombre;

-- ==========================================================
-- 6. BORRADO LOGICO.
-- Se marca temporalmente como inactivo el producto 6.
-- No se elimina el registro fisicamente.
-- ==========================================================

UPDATE producto
SET activo = FALSE
WHERE id_producto = 6
RETURNING id_producto, nombre, activo;

SELECT id_producto, nombre, activo
FROM producto
WHERE id_producto = 6;

-- Restaurar el estado original de la copia despues de la prueba.

UPDATE producto
SET activo = TRUE
WHERE id_producto = 6;

-- ==========================================================
-- 7. TRANSACCION CON DOS O MAS TABLAS.
-- Incluye SAVEPOINT, rollback parcial y COMMIT final.
-- ==========================================================

BEGIN;

-- Crear el producto padre.

INSERT INTO producto (nombre, marca, vida_util, id_categoria)
SELECT
    'Kit transaccional EcoData - ejercicio 2.4',
    'EcoData',
    '3 años',
    id_categoria
FROM categoria
WHERE id_categoria = 6
ON CONFLICT (nombre, id_categoria) DO NOTHING;

-- Crear la relacion con el material.

INSERT INTO producto_material (id_producto, id_material)
SELECT p.id_producto, 5
FROM producto p
WHERE p.nombre =
    'Kit transaccional EcoData - ejercicio 2.4'
ON CONFLICT (id_producto, id_material) DO NOTHING;

-- Punto de recuperacion antes de registrar el impacto.

SAVEPOINT antes_de_impacto;

-- Esta insercion se revertira parcialmente.

INSERT INTO impacto_ambiental
    (id_producto, id_fuente, consumo_agua,
     consumo_energia, emisiones_co2, residuos_generados,
     nivel_impacto, fecha_dato)
SELECT
    p.id_producto,
    2,
    10.00,
    2.50,
    0.065000,
    0.20,
    'Bajo (caso nacional)',
    CURRENT_DATE
FROM producto p
WHERE p.nombre =
    'Kit transaccional EcoData - ejercicio 2.4';

-- Revertir solamente la insercion del impacto.

ROLLBACK TO SAVEPOINT antes_de_impacto;

-- Se conserva el producto y su material.
-- Se agrega la especializacion reutilizable.

INSERT INTO producto_reutilizable
    (id_producto, numero_reutilizaciones, requiere_mantenimiento)
SELECT id_producto, 100, TRUE
FROM producto
WHERE nombre =
    'Kit transaccional EcoData - ejercicio 2.4'
ON CONFLICT (id_producto) DO NOTHING;

-- Confirmar los cambios que permanecen.

COMMIT;

-- Verificar el resultado de la transaccion.

SELECT
    p.id_producto,
    p.nombre,
    COUNT(DISTINCT pm.id_material) AS materiales,
    COUNT(DISTINCT pr.id_producto) AS subtipos_reutilizables,
    COUNT(DISTINCT ia.id_impacto) AS impactos
FROM producto p
LEFT JOIN producto_material pm
    ON pm.id_producto = p.id_producto
LEFT JOIN producto_reutilizable pr
    ON pr.id_producto = p.id_producto
LEFT JOIN impacto_ambiental ia
    ON ia.id_producto = p.id_producto
WHERE p.nombre =
    'Kit transaccional EcoData - ejercicio 2.4'
GROUP BY p.id_producto, p.nombre;

-- Limpiar el producto de demostracion despues de verificar
-- el COMMIT. CASCADE elimina sus asociaciones y subtipo.

BEGIN;

DELETE FROM producto
WHERE nombre =
    'Kit transaccional EcoData - ejercicio 2.4'
RETURNING id_producto, nombre;

COMMIT;

\echo 'FIN: operaciones DML y transaccion completadas.'
