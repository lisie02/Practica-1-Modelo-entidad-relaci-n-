-- Practica 5 - Ejercicio 2.3
-- Pruebas de integridad referencial de EcoData.
-- EJECUTAR EXCLUSIVAMENTE EN ecodata_pruebas.
-- Todos los cambios se revierten al finalizar.

DO $$
BEGIN
    IF current_database() <> 'ecodata_pruebas' THEN
        RAISE EXCEPTION
            'Prueba detenida: ejecutar exclusivamente en ecodata_pruebas.';
    END IF;
END;
$$;

BEGIN;

-- ==========================================================
-- PRUEBA 1. ON DELETE RESTRICT: categoria con productos.
-- ==========================================================

DO $$
DECLARE
    v_antes INTEGER;
    v_despues INTEGER;
    v_mensaje TEXT;
BEGIN
    SELECT COUNT(*) INTO v_antes
    FROM producto WHERE id_categoria = 5;

    BEGIN
        DELETE FROM categoria WHERE id_categoria = 5;
        RAISE EXCEPTION 'ERROR: se permitio eliminar una categoria utilizada.';
    EXCEPTION
        WHEN SQLSTATE '23001' THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            SELECT COUNT(*) INTO v_despues
            FROM producto WHERE id_categoria = 5;

            RAISE NOTICE
                'PRUEBA 1 CORRECTA: RESTRICT rechazo el borrado. Productos antes: %, despues: %. Mensaje: %',
                v_antes, v_despues, v_mensaje;
    END;
END;
$$;

-- ==========================================================
-- PRUEBA 2. ON DELETE RESTRICT: fuente con impactos.
-- ==========================================================

DO $$
DECLARE
    v_antes INTEGER;
    v_despues INTEGER;
    v_mensaje TEXT;
BEGIN
    SELECT COUNT(*) INTO v_antes
    FROM impacto_ambiental WHERE id_fuente = 2;

    BEGIN
        DELETE FROM fuente WHERE id_fuente = 2;
        RAISE EXCEPTION 'ERROR: se permitio eliminar una fuente utilizada.';
    EXCEPTION
        WHEN SQLSTATE '23001' THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            SELECT COUNT(*) INTO v_despues
            FROM impacto_ambiental WHERE id_fuente = 2;

            RAISE NOTICE
                'PRUEBA 2 CORRECTA: RESTRICT protegio la fuente. Impactos antes: %, despues: %. Mensaje: %',
                v_antes, v_despues, v_mensaje;
    END;
END;
$$;

-- ==========================================================
-- PRUEBA 3. ON DELETE RESTRICT: producto con impactos.
-- ==========================================================

DO $$
DECLARE
    v_antes INTEGER;
    v_despues INTEGER;
    v_mensaje TEXT;
BEGIN
    SELECT COUNT(*) INTO v_antes
    FROM impacto_ambiental WHERE id_producto = 4;

    BEGIN
        DELETE FROM producto WHERE id_producto = 4;
        RAISE EXCEPTION 'ERROR: se permitio eliminar un producto con impactos.';
    EXCEPTION
        WHEN SQLSTATE '23001' THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            SELECT COUNT(*) INTO v_despues
            FROM impacto_ambiental WHERE id_producto = 4;

            RAISE NOTICE
                'PRUEBA 3 CORRECTA: RESTRICT protegio el producto. Impactos antes: %, despues: %. Mensaje: %',
                v_antes, v_despues, v_mensaje;
    END;
END;
$$;

-- ==========================================================
-- PRUEBA 4. ON DELETE SET NULL: pais opcional.
-- Se asigna temporalmente Mexico al producto 4.
-- Al eliminar el pais, el producto debe conservarse.
-- ==========================================================

DO $$
DECLARE
    v_pais INTEGER;
    v_nombre TEXT;
    v_productos_pais INTEGER;
BEGIN
    UPDATE producto
    SET id_pais = 2
    WHERE id_producto = 4;

    SELECT COUNT(*) INTO v_productos_pais
    FROM producto WHERE id_pais = 2;

    DELETE FROM pais WHERE id_pais = 2;

    SELECT id_pais, nombre
    INTO v_pais, v_nombre
    FROM producto
    WHERE id_producto = 4;

    IF v_pais IS NULL AND v_nombre IS NOT NULL THEN
        RAISE NOTICE
            'PRUEBA 4 CORRECTA: SET NULL elimino la referencia al pais y conservo el producto. Productos que referenciaban Mexico antes del borrado: %.',
            v_productos_pais;
    ELSE
        RAISE EXCEPTION 'ERROR: SET NULL no se comporto como se esperaba.';
    END IF;
END;
$$;

-- ==========================================================
-- PRUEBA 5. ON DELETE CASCADE desde producto.
-- Se crea un producto temporal, un subtipo y una asociacion.
-- Al borrar el producto, desaparecen sus filas dependientes.
-- ==========================================================

DO $$
DECLARE
    v_producto INTEGER;
    v_subtipo_antes INTEGER;
    v_relacion_antes INTEGER;
    v_subtipo_despues INTEGER;
    v_relacion_despues INTEGER;
BEGIN
    INSERT INTO producto (nombre, id_categoria)
    VALUES (
        'Producto temporal prueba CASCADE',
        (SELECT MIN(id_categoria) FROM categoria)
    )
    RETURNING id_producto INTO v_producto;

    INSERT INTO producto_reutilizable
        (id_producto, numero_reutilizaciones, requiere_mantenimiento)
    VALUES (v_producto, 20, FALSE);

    INSERT INTO producto_material (id_producto, id_material)
    VALUES (v_producto, 2);

    SELECT COUNT(*) INTO v_subtipo_antes
    FROM producto_reutilizable WHERE id_producto = v_producto;

    SELECT COUNT(*) INTO v_relacion_antes
    FROM producto_material WHERE id_producto = v_producto;

    DELETE FROM producto WHERE id_producto = v_producto;

    SELECT COUNT(*) INTO v_subtipo_despues
    FROM producto_reutilizable WHERE id_producto = v_producto;

    SELECT COUNT(*) INTO v_relacion_despues
    FROM producto_material WHERE id_producto = v_producto;

    IF v_subtipo_despues = 0 AND v_relacion_despues = 0 THEN
        RAISE NOTICE
            'PRUEBA 5 CORRECTA: CASCADE elimino el producto y sus dependencias. Subtipo antes/despues: %/%. Relaciones antes/despues: %/%.',
            v_subtipo_antes, v_subtipo_despues,
            v_relacion_antes, v_relacion_despues;
    ELSE
        RAISE EXCEPTION 'ERROR: CASCADE no elimino todas las dependencias.';
    END IF;
END;
$$;

-- ==========================================================
-- PRUEBA 6. ON DELETE CASCADE desde material.
-- La asociacion se elimina, pero el producto permanece.
-- ==========================================================

DO $$
DECLARE
    v_antes INTEGER;
    v_despues INTEGER;
    v_productos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_antes
    FROM producto_material WHERE id_material = 2;

    DELETE FROM material WHERE id_material = 2;

    SELECT COUNT(*) INTO v_despues
    FROM producto_material WHERE id_material = 2;

    SELECT COUNT(*) INTO v_productos
    FROM producto WHERE id_producto = 4;

    IF v_despues = 0 AND v_productos = 1 THEN
        RAISE NOTICE
            'PRUEBA 6 CORRECTA: CASCADE elimino las asociaciones del material. Relaciones antes/despues: %/%. Producto conservado: %.',
            v_antes, v_despues, v_productos;
    ELSE
        RAISE EXCEPTION 'ERROR: CASCADE no produjo el resultado esperado al borrar material.';
    END IF;
END;
$$;

-- ==========================================================
-- PRUEBA 7. ON UPDATE CASCADE.
-- Se modifica temporalmente la clave de una categoria.
-- Los productos deben conservar la referencia actualizada.
-- ==========================================================

DO $$
DECLARE
    v_nuevo_id INTEGER;
    v_antes INTEGER;
    v_despues INTEGER;
    v_antiguos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_antes
    FROM producto WHERE id_categoria = 5;

    SELECT COALESCE(MAX(id_categoria), 0) + 1000
    INTO v_nuevo_id
    FROM categoria;

    UPDATE categoria
    SET id_categoria = v_nuevo_id
    WHERE id_categoria = 5;

    SELECT COUNT(*) INTO v_despues
    FROM producto WHERE id_categoria = v_nuevo_id;

    SELECT COUNT(*) INTO v_antiguos
    FROM producto WHERE id_categoria = 5;

    IF v_despues = v_antes AND v_antiguos = 0 THEN
        RAISE NOTICE
            'PRUEBA 7 CORRECTA: ON UPDATE CASCADE traslado las referencias. Antes: %, con nueva clave: %, con clave anterior: %.',
            v_antes, v_despues, v_antiguos;
    ELSE
        RAISE EXCEPTION 'ERROR: ON UPDATE CASCADE no actualizo las referencias.';
    END IF;
END;
$$;

-- ==========================================================
-- PRUEBA 8. INSERT con clave foranea inexistente.
-- ==========================================================

DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO producto (nombre, id_categoria, id_pais)
        VALUES (
            'Producto temporal con pais inexistente',
            (SELECT MIN(id_categoria) FROM categoria),
            9999999
        );

        RAISE EXCEPTION 'ERROR: se permitio una clave foranea inexistente.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE
                'PRUEBA 8 CORRECTA: PostgreSQL rechazo la clave foranea inexistente. %',
                v_mensaje;
    END;
END;
$$;

-- ==========================================================
-- PRUEBA 9. Orden de carga: primero el hijo y despues el padre.
-- La primera insercion debe fallar. Luego se crea el padre
-- y se inserta correctamente la relacion hija.
-- ==========================================================

DO $$
DECLARE
    v_producto INTEGER;
    v_material INTEGER;
    v_relaciones INTEGER;
    v_mensaje TEXT;
BEGIN
    SELECT COALESCE(MAX(id_producto), 0) + 1000000
    INTO v_producto
    FROM producto;

    SELECT MIN(id_material) INTO v_material
    FROM material;

    BEGIN
        INSERT INTO producto_material (id_producto, id_material)
        VALUES (v_producto, v_material);

        RAISE EXCEPTION 'ERROR: se permitio cargar el hijo antes del padre.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE
                'PRUEBA 9A CORRECTA: el hijo fue rechazado antes de crear el padre. %',
                v_mensaje;
    END;

    INSERT INTO producto (nombre, id_categoria)
    VALUES (
        'Producto temporal orden de carga',
        (SELECT MIN(id_categoria) FROM categoria)
    )
    RETURNING id_producto INTO v_producto;

    INSERT INTO producto_material (id_producto, id_material)
    VALUES (v_producto, v_material);

    SELECT COUNT(*) INTO v_relaciones
    FROM producto_material
    WHERE id_producto = v_producto
      AND id_material = v_material;

    IF v_relaciones = 1 THEN
        RAISE NOTICE
            'PRUEBA 9B CORRECTA: despues de crear el padre, se inserto la relacion hija.';
    ELSE
        RAISE EXCEPTION 'ERROR: no se pudo insertar la relacion despues del padre.';
    END IF;
END;
$$;

ROLLBACK;

\echo 'FIN: las pruebas terminaron y todos los cambios temporales fueron revertidos.'

