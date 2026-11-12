-- Practica 5 - Ejercicio 2.4
-- Migracion 004: habilitar el borrado logico de productos.
-- Aplicar exclusivamente en ecodata_pruebas.

BEGIN;

ALTER TABLE public.producto
ADD COLUMN activo BOOLEAN NOT NULL DEFAULT TRUE;

COMMIT;
