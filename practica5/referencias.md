# Ejercicio 2.1. Claves foráneas del proyecto propio

**Proyecto:** EcoData  
**Gestor:** PostgreSQL  
**Base de datos:** ecodata  
**Fecha de revisión:** 6 de noviembre de 2026

## 1. Objetivo

Identificar las claves foráneas del modelo relacional de EcoData, documentar las relaciones que representan y comprobar si admiten valores nulos de acuerdo con la cardinalidad mínima del modelo EER.

## 2. Inventario de claves foráneas

La consulta realizada sobre `information_schema` identificó ocho claves foráneas en el esquema `public`.

| Tabla hija | Columna FK | Tabla referenciada | Columna referenciada | ¿Admite NULL? | DELETE | UPDATE |
|---|---|---|---|---|---|---|
| impacto_ambiental | id_fuente | fuente | id_fuente | No | NO ACTION | NO ACTION |
| impacto_ambiental | id_producto | producto | id_producto | No | NO ACTION | NO ACTION |
| producto | id_categoria | categoria | id_categoria | No | NO ACTION | NO ACTION |
| producto | id_pais | pais | id_pais | Sí | NO ACTION | NO ACTION |
| producto_desechable | id_producto | producto | id_producto | No | NO ACTION | NO ACTION |
| producto_material | id_producto | producto | id_producto | No | NO ACTION | NO ACTION |
| producto_material | id_material | material | id_material | No | NO ACTION | NO ACTION |
| producto_reutilizable | id_producto | producto | id_producto | No | NO ACTION | NO ACTION |

## 3. Correspondencia con las relaciones del modelo EER

### 3.1 Categoría–Producto

- **Clave foránea:** `producto.id_categoria`.
- **Referencia:** `categoria.id_categoria`.
- **Relación EER:** una categoría agrupa productos.
- **Cardinalidad:** una categoría puede relacionarse con cero o muchos productos; cada producto pertenece obligatoriamente a una categoría.
- **Admite NULL:** no.

La participación del producto es obligatoria, por eso la columna `id_categoria` está declarada como `NOT NULL`.

### 3.2 País–Producto

- **Clave foránea:** `producto.id_pais`.
- **Referencia:** `pais.id_pais`.
- **Relación EER:** un país puede ser el país de fabricación de varios productos.
- **Cardinalidad:** un país puede estar relacionado con cero o muchos productos; un producto puede tener cero o un país registrado.
- **Admite NULL:** sí.

La relación es opcional para el producto porque puede no conocerse o no existir información confirmada sobre su país de fabricación. Se permite `NULL` para no registrar un origen que no esté respaldado por evidencia.

### 3.3 Producto–Impacto ambiental

- **Clave foránea:** `impacto_ambiental.id_producto`.
- **Referencia:** `producto.id_producto`.
- **Relación EER:** un producto puede contar con varios registros de impacto ambiental.
- **Cardinalidad:** un producto puede tener cero o muchos registros de impacto; cada impacto corresponde obligatoriamente a un producto.
- **Admite NULL:** no.

La medición ambiental necesita identificar el producto que está siendo evaluado.

### 3.4 Fuente–Impacto ambiental

- **Clave foránea:** `impacto_ambiental.id_fuente`.
- **Referencia:** `fuente.id_fuente`.
- **Relación EER:** una fuente documental puede respaldar varios registros de impacto.
- **Cardinalidad:** una fuente puede respaldar cero o muchos impactos; cada registro de impacto debe estar respaldado por una fuente.
- **Admite NULL:** no.

Esta regla permite identificar la procedencia de los datos ambientales y conservar su trazabilidad.

### 3.5 Producto–Material

La relación muchos a muchos se transforma mediante la tabla asociativa `producto_material`.

**Primera clave foránea:**

- `producto_material.id_producto` referencia `producto.id_producto`.

**Segunda clave foránea:**

- `producto_material.id_material` referencia `material.id_material`.

Cada renglón de `producto_material` debe identificar exactamente un producto y un material. Ambos campos son obligatorios y, junto con la clave primaria compuesta, impiden repetir la misma pareja.

Un producto puede estar compuesto por varios materiales y un material puede participar en varios productos.

### 3.6 Jerarquía ISA: Producto reutilizable y desechable

La especialización del producto se implementó con dos tablas de subtipo.

**Producto reutilizable:**

- `producto_reutilizable.id_producto` referencia `producto.id_producto`.
- El identificador es simultáneamente PK y FK.
- No admite `NULL`.
- Cada producto reutilizable debe existir previamente en `producto`.

**Producto desechable:**

- `producto_desechable.id_producto` referencia `producto.id_producto`.
- El identificador es simultáneamente PK y FK.
- No admite `NULL`.
- Cada producto desechable debe existir previamente en `producto`.

La jerarquía es parcial: un producto puede no estar clasificado en ninguno de los subtipos. También se estableció la disyunción mediante disparadores para impedir que el mismo producto aparezca simultáneamente en ambos subtipos.

## 4. Justificación de los valores NULL

La revisión identificó una sola clave foránea opcional:

| Columna | ¿Por qué admite NULL? |
|---|---|
| `producto.id_pais` | El país de fabricación puede no conocerse o no estar confirmado. |

Las otras siete claves foráneas son obligatorias porque la entidad hija necesita identificar al registro padre para tener sentido dentro del modelo.

Es importante distinguir que una clave foránea obligatoria en la tabla hija no obliga a que cada registro padre tenga hijos. Por ejemplo, una categoría puede existir aunque todavía no tenga productos registrados.

## 5. Acciones referenciales actuales

La consulta de PostgreSQL mostró `NO ACTION` para las acciones de eliminación y actualización de las ocho claves foráneas.

Esto significa que el gestor impide eliminar o modificar una clave primaria referenciada mientras existan registros dependientes que quedarían sin correspondencia.

No se declararon explícitamente acciones `ON DELETE` ni `ON UPDATE` diferentes en las restricciones revisadas.

En el ejercicio 2.2 se evaluará si conviene conservar o cambiar estas acciones de acuerdo con las reglas del dominio de EcoData.

## 6. Consulta utilizada para obtener el inventario

```sql
SELECT
    tc.table_name AS tabla_hija,
    kcu.column_name AS columna_fk,
    ccu.table_name AS tabla_referenciada,
    ccu.column_name AS columna_referenciada,
    col.is_nullable AS admite_null,
    rc.delete_rule AS regla_delete,
    rc.update_rule AS regla_update,
    tc.constraint_name AS restriccion
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.constraint_schema = kcu.constraint_schema
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.constraint_schema = ccu.constraint_schema
JOIN information_schema.columns col
    ON col.table_schema = tc.table_schema
   AND col.table_name = tc.table_name
   AND col.column_name = kcu.column_name
LEFT JOIN information_schema.referential_constraints rc
    ON rc.constraint_schema = tc.constraint_schema
   AND rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.ordinal_position;
```

## 7. Conclusión

El inventario permitió identificar las ocho claves foráneas de EcoData y relacionarlas con las asociaciones del modelo EER.

Siete claves son obligatorias y una, `producto.id_pais`, admite valores nulos porque el país de fabricación es un dato opcional. También se confirmó que la relación muchos a muchos entre productos y materiales se implementa mediante una tabla asociativa y que la jerarquía ISA utiliza claves primarias que también funcionan como claves foráneas.

Por último, las ocho relaciones utilizan actualmente `NO ACTION` para borrar y actualizar. Esta configuración protege la integridad referencial, aunque en el siguiente ejercicio se revisará si algunas relaciones requieren una acción distinta.

## 7. Ejercicio 2.2. Acciones referenciales

Se revisaron las ocho claves foráneas del esquema de EcoData y se eligieron acciones referenciales de acuerdo con las reglas del dominio.

| Tabla hija | Clave foránea | ON DELETE | ON UPDATE | Justificación |
|---|---|---|---|---|
| impacto_ambiental | id_fuente | RESTRICT | CASCADE | Una fuente que respalda mediciones ambientales no debe eliminarse mientras existan registros dependientes. |
| impacto_ambiental | id_producto | RESTRICT | CASCADE | Se conserva el historial ambiental de los productos. |
| producto | id_categoria | RESTRICT | CASCADE | No se elimina una categoría mientras tenga productos asociados. |
| producto | id_pais | SET NULL | CASCADE | El producto puede seguir existiendo aunque se elimine el registro de país, ya que su origen es opcional. |
| producto_desechable | id_producto | CASCADE | CASCADE | El subtipo no puede existir sin su producto padre. |
| producto_material | id_producto | CASCADE | CASCADE | La asociación se elimina cuando desaparece el producto. |
| producto_material | id_material | CASCADE | CASCADE | La asociación se elimina cuando desaparece el material. |
| producto_reutilizable | id_producto | CASCADE | CASCADE | El subtipo no puede existir sin su producto padre. |

### Justificación general

Se eligió `RESTRICT` para las relaciones que conservan información importante del proyecto, como las fuentes documentales, los impactos ambientales y las categorías. Así se evita eliminar accidentalmente registros que todavía tienen información dependiente.

Se eligió `SET NULL` para `producto.id_pais`, porque el país de fabricación es una relación opcional y un producto puede conservarse aunque su país deje de estar registrado.

Se eligió `CASCADE` para las tablas de especialización y la tabla asociativa `producto_material`. Estas filas dependen directamente del producto o material padre y no tienen sentido de forma independiente.

Para las actualizaciones se eligió `CASCADE`, con el propósito de propagar un eventual cambio de identificador a las referencias dependientes. Aunque los identificadores son estables y normalmente no se modifican, esta acción mantiene la integridad si ocurre una actualización.

La migración se probará en una copia de la base de datos para conservar intacta la base original.

### Migración

Los cambios están definidos en:

`practica5/sql/001-acciones-referenciales.sql`

El archivo elimina y vuelve a crear cada clave foránea conservando su nombre, pero especificando las acciones referenciales elegidas.
