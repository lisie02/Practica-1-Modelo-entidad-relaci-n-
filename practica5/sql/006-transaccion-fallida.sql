-- Practica 5 - Ejercicio 2.4
-- Transaccion que falla a mitad de ejecucion.
-- Ejecutar exclusivamente en ecodata_pruebas.

DO $$
BEGIN
    IF current_database() <> 'ecodata_pruebas' THEN
        RAISE EXCEPTION
            'Prueba detenida: ejecutar exclusivamente en ecodata_pruebas.';
    END IF;
END;
$$;

BEGIN;

-- Primera operacion: se modifica correctamente el precio.
UPDATE producto
SET precio_aproximado = 123.45
WHERE id_producto = 4
RETURNING id_producto, nombre, precio_aproximado;

-- Segunda operacion: debe fallar porque las emisiones
-- de CO2 no pueden ser negativas.
UPDATE impacto_ambiental
SET emisiones_co2 = -1
WHERE id_impacto = 1;

-- PostgreSQL revertira la transaccion porque quedo abortada.
COMMIT;
