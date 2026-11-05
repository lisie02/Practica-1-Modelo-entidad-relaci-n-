
-- Pruebas de restricciones para EcoData
-- Ejecutar después de crear las tablas de esquema.sql.

-- PRUEBA 1: debe rechazarse una categoría sin nombre
-- porque la columna nombre tiene la restricción NOT NULL.
DO $$
BEGIN
    BEGIN
        INSERT INTO categoria (nombre)
        VALUES (NULL);

        RAISE EXCEPTION 'ERROR: se aceptó una categoría sin nombre';
    EXCEPTION
        WHEN not_null_violation THEN
            RAISE NOTICE 'PRUEBA 1 CORRECTA: se rechazó el nombre nulo';
    END;
END;
$$;

-- PRUEBA 2: debe rechazarse un producto con una categoría
-- inexistente, por la clave foránea id_categoria.
DO $$
BEGIN
    BEGIN
        INSERT INTO producto (nombre, id_categoria)
        VALUES ('Producto de prueba inválido', 999999999);

        RAISE EXCEPTION 'ERROR: se aceptó una categoría inexistente';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'PRUEBA 2 CORRECTA: se rechazó la categoría inexistente';
    END;
END;
$$;

-- PRUEBA 3: debe rechazarse una relación producto-material
-- cuyo producto no existe, por la clave foránea id_producto.
DO $$
BEGIN
    BEGIN
        INSERT INTO producto_material (id_producto, id_material)
        VALUES (999999999, 999999998);

        RAISE EXCEPTION 'ERROR: se aceptó un producto inexistente';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'PRUEBA 3 CORRECTA: se rechazó el producto inexistente';
    END;
END;
$$;
