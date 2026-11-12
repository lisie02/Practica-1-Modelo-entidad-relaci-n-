
-- Practica 5 - Ejercicio 2.2
-- Migracion 001: acciones referenciales de EcoData.
-- Aplicar primero en la copia ecodata_pruebas.
-- La base original ecodata no debe modificarse durante las pruebas.

BEGIN;

-- Impacto ambiental: conservar la trazabilidad de las fuentes.
ALTER TABLE public.impacto_ambiental
DROP CONSTRAINT impacto_ambiental_id_fuente_fkey;

ALTER TABLE public.impacto_ambiental
ADD CONSTRAINT impacto_ambiental_id_fuente_fkey
FOREIGN KEY (id_fuente)
REFERENCES public.fuente(id_fuente)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- Impacto ambiental: conservar el historial del producto.
ALTER TABLE public.impacto_ambiental
DROP CONSTRAINT impacto_ambiental_id_producto_fkey;

ALTER TABLE public.impacto_ambiental
ADD CONSTRAINT impacto_ambiental_id_producto_fkey
FOREIGN KEY (id_producto)
REFERENCES public.producto(id_producto)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- Producto: proteger las categorias que tienen productos.
ALTER TABLE public.producto
DROP CONSTRAINT producto_id_categoria_fkey;

ALTER TABLE public.producto
ADD CONSTRAINT producto_id_categoria_fkey
FOREIGN KEY (id_categoria)
REFERENCES public.categoria(id_categoria)
ON DELETE RESTRICT
ON UPDATE CASCADE;

-- Producto: el pais es opcional.
ALTER TABLE public.producto
DROP CONSTRAINT producto_id_pais_fkey;

ALTER TABLE public.producto
ADD CONSTRAINT producto_id_pais_fkey
FOREIGN KEY (id_pais)
REFERENCES public.pais(id_pais)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- Subtipo desechable: depende del producto padre.
ALTER TABLE public.producto_desechable
DROP CONSTRAINT producto_desechable_id_producto_fkey;

ALTER TABLE public.producto_desechable
ADD CONSTRAINT producto_desechable_id_producto_fkey
FOREIGN KEY (id_producto)
REFERENCES public.producto(id_producto)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Tabla asociativa: eliminar la relacion al borrar el producto.
ALTER TABLE public.producto_material
DROP CONSTRAINT producto_material_id_producto_fkey;

ALTER TABLE public.producto_material
ADD CONSTRAINT producto_material_id_producto_fkey
FOREIGN KEY (id_producto)
REFERENCES public.producto(id_producto)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Tabla asociativa: eliminar la relacion al borrar el material.
ALTER TABLE public.producto_material
DROP CONSTRAINT producto_material_id_material_fkey;

ALTER TABLE public.producto_material
ADD CONSTRAINT producto_material_id_material_fkey
FOREIGN KEY (id_material)
REFERENCES public.material(id_material)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Subtipo reutilizable: depende del producto padre.
ALTER TABLE public.producto_reutilizable
DROP CONSTRAINT producto_reutilizable_id_producto_fkey;

ALTER TABLE public.producto_reutilizable
ADD CONSTRAINT producto_reutilizable_id_producto_fkey
FOREIGN KEY (id_producto)
REFERENCES public.producto(id_producto)
ON DELETE CASCADE
ON UPDATE CASCADE;

COMMIT;
