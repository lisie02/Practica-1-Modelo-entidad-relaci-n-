# Ejercicio 2.1. Las claves foráneas del proyecto propio (EcoData)

Este documento lista cada clave foránea del esquema de EcoData (`docs/esquema.sql`), la relación del modelo EER que implementa, la tabla y columna que referencia, y si admite nulos según la cardinalidad mínima de la relación (ver `proyecto-propio/inventario-eer.md`, sección 4).

Los nombres de las restricciones son los que PostgreSQL asigna por omisión (`<tabla>_<columna>_fkey`), porque en `esquema.sql` se declararon sin `CONSTRAINT <nombre>`. Pueden comprobarse con la consulta de `sql/listar-claves-foraneas.sql`.

## Tabla de claves foráneas

| # | Tabla (hija) | Columna | Referencia (padre) | Relación EER que implementa | Cardinalidad mínima del lado hijo | ¿Admite NULL? | Restricción en PostgreSQL |
|---|---|---|---|---|---|---|---|
| 1 | `producto` | `id_categoria` | `categoria(id_categoria)` | **Pertenece a** (CATEGORIA 0,N — PRODUCTO 1,1) | 1: todo producto debe tener categoría | **No** (`NOT NULL`) | `producto_id_categoria_fkey` |
| 2 | `producto` | `id_pais` | `pais(id_pais)` | **Se fabrica en** (PAIS 0,N — PRODUCTO 0,1) | 0: el país de fabricación puede no estar confirmado | **Sí** | `producto_id_pais_fkey` |
| 3 | `producto_material` | `id_producto` | `producto(id_producto)` | **Compuesto por** (PRODUCTO N:M MATERIAL), tabla asociativa | 1: un renglón de la asociación siempre es de un producto | **No** (`NOT NULL` y parte de la PK) | `producto_material_id_producto_fkey` |
| 4 | `producto_material` | `id_material` | `material(id_material)` | **Compuesto por** (PRODUCTO N:M MATERIAL), tabla asociativa | 1: un renglón de la asociación siempre es de un material | **No** (`NOT NULL` y parte de la PK) | `producto_material_id_material_fkey` |
| 5 | `impacto_ambiental` | `id_producto` | `producto(id_producto)` | **Tiene** (PRODUCTO 0,N — IMPACTO_AMBIENTAL 1,1) | 1: cada medición es de un producto | **No** (`NOT NULL`) | `impacto_ambiental_id_producto_fkey` |
| 6 | `impacto_ambiental` | `id_fuente` | `fuente(id_fuente)` | **Se obtiene de** (FUENTE 0,N — IMPACTO_AMBIENTAL 1,1) | 1: todo dato de impacto debe tener fuente citable | **No** (`NOT NULL`) | `impacto_ambiental_id_fuente_fkey` |
| 7 | `producto_reutilizable` | `id_producto` | `producto(id_producto)` | **Especialización ISA** PRODUCTO → PRODUCTO_REUTILIZABLE (1:1) | 1: un subtipo no existe sin su supertipo | **No** (es la PK) | `producto_reutilizable_id_producto_fkey` |
| 8 | `producto_desechable` | `id_producto` | `producto(id_producto)` | **Especialización ISA** PRODUCTO → PRODUCTO_DESECHABLE (1:1) | 1: un subtipo no existe sin su supertipo | **No** (es la PK) | `producto_desechable_id_producto_fkey` |

En total, el esquema declara **8 claves foráneas** sobre 5 tablas hijas.

## Reglas del dominio que justifican la nulabilidad

1. `producto.id_categoria` — *Todo producto se clasifica en una categoría para poder compararlo con otros del mismo tipo.*
2. `producto.id_pais` — *No se afirma un país de fabricación que la fuente no confirma* (ver `practica4/fuente.md`: el estudio de envases de 355 ml no indica dónde se fabricó cada envase).
3. y 4. `producto_material.*` — *Una composición sin producto o sin material no describe nada.*
5. `impacto_ambiental.id_producto` — *Un dato de impacto siempre se mide sobre un producto concreto.*
6. `impacto_ambiental.id_fuente` — *Ningún dato ambiental entra a la base sin una fuente citable.*
7. y 8. Subtipos — *Un producto reutilizable o desechable es, antes que nada, un producto registrado.*

## Relaciones del modelo EER revisadas

Todas las relaciones del diagrama EER quedaron implementadas como clave foránea; no fue necesario agregar ninguna con migración.

| Relación EER | ¿Quedó como FK? | Observación |
|---|---|---|
| Pertenece a (CATEGORIA–PRODUCTO) | Sí (#1) | — |
| Se fabrica en (PAIS–PRODUCTO) | Sí (#2) | Ver la discrepancia de cardinalidad abajo. |
| Compuesto por (PRODUCTO–MATERIAL) | Sí (#3 y #4) | La N:M se resuelve con la tabla asociativa `producto_material` y su PK compuesta `(id_producto, id_material)`. |
| Tiene (PRODUCTO–IMPACTO_AMBIENTAL) | Sí (#5) | — |
| Se obtiene de (FUENTE–IMPACTO_AMBIENTAL) | Sí (#6) | — |
| ISA PRODUCTO → subtipos | Sí (#7 y #8) | La **disyunción** no puede expresarse con una FK; se implementa con el disparador `verificar_disyuncion_producto()` de `esquema.sql`. La **completitud** es parcial, así que no hace falta exigir que todo producto aparezca en algún subtipo. |
| EVIDENCIA_IMPACTO | No aplica | No aparece en el diagrama EER entregado (inventario, sección 3.2), por lo que no se crea tabla ni FK. |

### Discrepancia: cardinalidad de "Se fabrica en"

El inventario EER (Práctica 3) propuso PRODUCTO **(1,1)** en la relación con PAIS, lo que exigiría `id_pais NOT NULL`. Al cargar datos reales en la Práctica 4 se decidió que la columna admita `NULL`, porque la fuente no confirma el país de fabricación de los envases (`practica4/dominios.md`). Se corrige la cardinalidad del modelo a **PRODUCTO (0,1)** en lugar de forzar un `NOT NULL` que obligaría a inventar datos. Por eso la clave #2 admite nulos, y la acción referencial que le corresponde en el ejercicio 2.2 es `ON DELETE SET NULL`.

## Comprobación en el gestor

```sql
SELECT
    con.conname                       AS restriccion,
    con.conrelid::regclass            AS tabla_hija,
    att.attname                       AS columna,
    con.confrelid::regclass           AS tabla_padre,
    att_ref.attname                   AS columna_referenciada,
    NOT att.attnotnull                AS admite_null,
    con.confdeltype                   AS on_delete,   -- a = NO ACTION, r = RESTRICT, c = CASCADE, n = SET NULL, d = SET DEFAULT
    con.confupdtype                   AS on_update
FROM pg_constraint con
JOIN pg_attribute att
  ON att.attrelid = con.conrelid AND att.attnum = ANY (con.conkey)
JOIN pg_attribute att_ref
  ON att_ref.attrelid = con.confrelid AND att_ref.attnum = ANY (con.confkey)
WHERE con.contype = 'f'
  AND con.connamespace = 'public'::regnamespace
ORDER BY tabla_hija::text, columna;
```

El resultado esperado son 8 renglones, uno por cada clave de la tabla anterior. Con el esquema de la Práctica 3 todas aparecen con `on_delete = a` y `on_update = a` (`NO ACTION`, el valor por omisión); las acciones definitivas se asignan en el ejercicio 2.2 con la migración `002-referencias.sql`.
