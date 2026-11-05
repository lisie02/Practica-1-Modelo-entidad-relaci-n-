-- Practica 4 - Ejercicio 1.5
-- Diez pruebas de restricciones de dominio en EcoData.
-- Todas las pruebas se ejecutan dentro de una transaccion.
-- Al terminar, ROLLBACK restaura la base de datos.

BEGIN;

-- PRUEBA 1. NOT NULL: nombre del producto.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO producto (nombre, id_categoria)
        VALUES (NULL, (SELECT MIN(id_categoria) FROM categoria));

        RAISE EXCEPTION 'ERROR: se permitio un producto sin nombre.';
    EXCEPTION
        WHEN not_null_violation OR check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 1 CORRECTA: NOT NULL rechazo el nombre. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 2. DEFAULT: fecha de consulta automatica.
DO $$
DECLARE
    v_fecha DATE;
BEGIN
    INSERT INTO fuente (nombre, tipo, url)
    VALUES (
        'Fuente temporal para prueba DEFAULT',
        'Prueba',
        'https://example.org/eco-prueba-default'
    )
    RETURNING fecha_consulta INTO v_fecha;

    IF v_fecha = CURRENT_DATE THEN
        RAISE NOTICE 'PRUEBA 2 CORRECTA: DEFAULT asigno la fecha actual (%).',
            v_fecha;
    ELSE
        RAISE EXCEPTION 'ERROR: DEFAULT no asigno la fecha esperada.';
    END IF;
END;
$$;

-- PRUEBA 3. UNIQUE simple: nombre del material.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO material (nombre)
        SELECT nombre FROM material LIMIT 1;

        RAISE EXCEPTION 'ERROR: se permitio un material duplicado.';
    EXCEPTION
        WHEN unique_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 3 CORRECTA: UNIQUE rechazo el material duplicado. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 4. UNIQUE simple: URL de la fuente.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO fuente (nombre, tipo, url)
        SELECT
            'Fuente temporal duplicada',
            'Prueba',
            url
        FROM fuente
        WHERE url IS NOT NULL
        LIMIT 1;

        RAISE EXCEPTION 'ERROR: se permitio una URL duplicada.';
    EXCEPTION
        WHEN unique_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 4 CORRECTA: UNIQUE rechazo la URL duplicada. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 5. UNIQUE compuesta: producto y categoria.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO producto (nombre, id_categoria)
        SELECT nombre, id_categoria
        FROM producto
        LIMIT 1;

        RAISE EXCEPTION 'ERROR: se permitio duplicar producto y categoria.';
    EXCEPTION
        WHEN unique_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 5 CORRECTA: UNIQUE compuesta rechazo el duplicado. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 6. PRIMARY KEY compuesta: producto_material.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO producto_material (id_producto, id_material)
        SELECT id_producto, id_material
        FROM producto_material
        LIMIT 1;

        RAISE EXCEPTION 'ERROR: se permitio duplicar la relacion.';
    EXCEPTION
        WHEN unique_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 6 CORRECTA: PK compuesta rechazo la relacion repetida. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 7. CHECK de rango: precio negativo.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO producto (nombre, precio_aproximado, id_categoria)
        VALUES (
            'Producto temporal para prueba de precio',
            -1,
            (SELECT MIN(id_categoria) FROM categoria)
        );

        RAISE EXCEPTION 'ERROR: se permitio un precio negativo.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 7 CORRECTA: CHECK rechazo el precio negativo. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 8. CHECK de rango: emisiones negativas.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        UPDATE impacto_ambiental
        SET emisiones_co2 = -1
        WHERE id_impacto = (
            SELECT MIN(id_impacto) FROM impacto_ambiental
        );

        RAISE EXCEPTION 'ERROR: se permitieron emisiones negativas.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 8 CORRECTA: CHECK rechazo emisiones negativas. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 9. CHECK de formato: URL incorrecta.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        INSERT INTO fuente (nombre, tipo, url)
        VALUES (
            'Fuente temporal con URL incorrecta',
            'Prueba',
            'ftp://direccion-no-permitida'
        );

        RAISE EXCEPTION 'ERROR: se permitio una URL incorrecta.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 9 CORRECTA: CHECK rechazo el formato de URL. %',
                v_mensaje;
    END;
END;
$$;

-- PRUEBA 10. CHECK entre columnas:
-- No puede existir nivel de impacto sin emisiones.
DO $$
DECLARE
    v_mensaje TEXT;
BEGIN
    BEGIN
        UPDATE impacto_ambiental
        SET nivel_impacto = 'Bajo (caso nacional)',
            emisiones_co2 = NULL
        WHERE id_impacto = (
            SELECT MIN(id_impacto) FROM impacto_ambiental
        );

        RAISE EXCEPTION 'ERROR: se permitio nivel de impacto sin emisiones.';
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_mensaje = MESSAGE_TEXT;
            RAISE NOTICE 'PRUEBA 10 CORRECTA: CHECK entre columnas rechazo la operacion. %',
                v_mensaje;
    END;
END;
$$;

ROLLBACK;

\echo 'FIN: diez pruebas ejecutadas. Los cambios temporales fueron revertidos.'
