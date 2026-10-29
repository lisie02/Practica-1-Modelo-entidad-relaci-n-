
-- ============================================================
-- EcoData: pruebas de restricciones de integridad
-- Practica 3 - Bases de Datos
--
-- Las pruebas provocan errores intencionales y los capturan
-- para mostrar el mensaje devuelto por PostgreSQL.
-- No dejan registros de prueba guardados.
-- ============================================================


-- ============================================================
-- PRUEBA 1: clave foranea
-- Un producto inexistente no puede relacionarse con material.
-- ============================================================

DO $$
BEGIN
    BEGIN
        INSERT INTO producto_material (id_producto, id_material)
        VALUES (999999, 999999);

        RAISE EXCEPTION
            'PRUEBA FALLIDA: se acepto una referencia inexistente';

    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE
                'PRUEBA 1 CORRECTA. PostgreSQL rechazo la insercion. Mensaje: %',
                SQLERRM;
    END;
END;
$$;


-- ============================================================
-- PRUEBA 2: clave primaria compuesta
-- No se permite repetir una relacion producto-material.
-- ============================================================

DO $$
DECLARE
    v_id_producto INTEGER;
    v_id_material INTEGER;
BEGIN
    SELECT pm.id_producto, pm.id_material
    INTO v_id_producto, v_id_material
    FROM producto_material pm
    JOIN producto p
        ON p.id_producto = pm.id_producto
    JOIN material m
        ON m.id_material = pm.id_material
    WHERE p.nombre = 'Botella PET para refresco de 355 ml'
      AND m.nombre = 'PET'
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'No existe la relacion PET necesaria para ejecutar la prueba 2';
    END IF;

    BEGIN
        INSERT INTO producto_material (id_producto, id_material)
        VALUES (v_id_producto, v_id_material);

        RAISE EXCEPTION
            'PRUEBA FALLIDA: se acepto una relacion duplicada';

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE
                'PRUEBA 2 CORRECTA. PostgreSQL rechazo la relacion duplicada. Mensaje: %',
                SQLERRM;
    END;
END;
$$;


-- ============================================================
-- PRUEBA 3: disyuncion de la jerarquia ISA
-- El mismo producto no puede ser reutilizable y desechable.
-- El registro temporal se elimina despues de la prueba.
-- ============================================================

DO $$
DECLARE
    v_id_producto INTEGER;
    v_mensaje TEXT;
BEGIN
    SELECT id_producto
    INTO v_id_producto
    FROM producto
    WHERE nombre = 'Botella PET para refresco de 355 ml';

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'No existe el producto necesario para ejecutar la prueba 3';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM producto_reutilizable
        WHERE id_producto = v_id_producto
    ) OR EXISTS (
        SELECT 1
        FROM producto_desechable
        WHERE id_producto = v_id_producto
    ) THEN
        RAISE EXCEPTION
            'El producto de prueba ya pertenece a un subtipo ISA';
    END IF;

    INSERT INTO producto_reutilizable (
        id_producto,
        numero_reutilizaciones,
        requiere_mantenimiento
    )
    VALUES (
        v_id_producto,
        10,
        FALSE
    );

    BEGIN
        INSERT INTO producto_desechable (
            id_producto,
            tiempo_descomposicion_anios,
            genera_residuos
        )
        VALUES (
            v_id_producto,
            1,
            TRUE
        );

        RAISE EXCEPTION
            'PRUEBA FALLIDA: se permitio pertenecer a ambos subtipos';

    EXCEPTION
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS
                v_mensaje = MESSAGE_TEXT;

            IF position('reutilizable' IN v_mensaje) > 0 THEN
                RAISE NOTICE
                    'PRUEBA 3 CORRECTA. PostgreSQL rechazo el segundo subtipo. Mensaje: %',
                    v_mensaje;
            ELSE
                RAISE;
            END IF;
    END;

    DELETE FROM producto_reutilizable
    WHERE id_producto = v_id_producto;
END;
$$;


-- Fin de las pruebas.
