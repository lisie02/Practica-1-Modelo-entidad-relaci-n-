-- Practica 5 - Ejercicio 2.6
-- Comparacion de RESTRICT y CASCADE.
-- Responsable: lisie02
-- Ejecutar exclusivamente en ecodata_individual_lisie.

DO $$
BEGIN
    IF current_database() <> 'ecodata_individual_lisie' THEN
        RAISE EXCEPTION
            'Error: ejecutar exclusivamente en ecodata_individual_lisie.';
    END IF;
END;
$$;

BEGIN;

-- Estado antes de eliminar el producto 4.
SELECT
    'ANTES' AS etapa,
    (SELECT COUNT(*) FROM producto WHERE id_producto = 4) AS producto,
    (SELECT COUNT(*) FROM impacto_ambiental WHERE id_producto = 4) AS impactos,
    (SELECT COUNT(*) FROM producto_material WHERE id_producto = 4) AS asociaciones,
    (SELECT COUNT(*) FROM material WHERE id_material = 2) AS material_pet,
    (SELECT COUNT(*) FROM fuente WHERE id_fuente = 2) AS fuente,
    (SELECT COUNT(*) FROM producto WHERE id_producto IN (5,6)) AS otros_productos;

-- Eliminar fisicamente la botella PET.
DELETE FROM producto
WHERE id_producto = 4
RETURNING id_producto, nombre;

-- Estado despues de eliminar el producto.
SELECT
    'DESPUES' AS etapa,
    (SELECT COUNT(*) FROM producto WHERE id_producto = 4) AS producto,
    (SELECT COUNT(*) FROM impacto_ambiental WHERE id_producto = 4) AS impactos,
    (SELECT COUNT(*) FROM producto_material WHERE id_producto = 4) AS asociaciones,
    (SELECT COUNT(*) FROM material WHERE id_material = 2) AS material_pet,
    (SELECT COUNT(*) FROM fuente WHERE id_fuente = 2) AS fuente,
    (SELECT COUNT(*) FROM producto WHERE id_producto IN (5,6)) AS otros_productos;

-- Revertir todos los cambios de la demostracion.
ROLLBACK;

\echo 'FIN: comparacion CASCADE terminada; los datos fueron restaurados.'
