-- Practica 5 - Ejercicio 2.6
-- Cambio individual de RESTRICT a CASCADE.
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

-- Modificar exclusivamente la relacion:
-- impacto_ambiental.id_producto -> producto.id_producto

ALTER TABLE public.impacto_ambiental
DROP CONSTRAINT impacto_ambiental_id_producto_fkey;

ALTER TABLE public.impacto_ambiental
ADD CONSTRAINT impacto_ambiental_id_producto_fkey
FOREIGN KEY (id_producto)
REFERENCES public.producto(id_producto)
ON DELETE CASCADE
ON UPDATE CASCADE;

COMMIT;

-- Consultar la nueva configuracion.

SELECT
    conname AS restriccion,
    pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE conname = 'impacto_ambiental_id_producto_fkey';
