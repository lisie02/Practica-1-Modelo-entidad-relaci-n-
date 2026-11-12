# Ejercicio 2.3. Pruebas de integridad referencial

**Proyecto:** EcoData  
**Gestor:** PostgreSQL  
**Base de pruebas:** `ecodata_pruebas`  
**Fecha:** 6 de noviembre de 2026

## 1. Objetivo

Comprobar mediante operaciones DML que las acciones referenciales definidas en el ejercicio 2.2 protegen las relaciones del modelo EcoData.

Todas las pruebas se ejecutaron en una copia de la base original. La transacción terminó con `ROLLBACK` para evitar modificaciones permanentes.

## 2. Conteos iniciales

Antes de las pruebas se consultaron las nueve tablas principales.

| Tabla | Registros iniciales |
|---|---:|
| categoria | 3 |
| pais | 1 |
| material | 4 |
| fuente | 3 |
| producto | 3 |
| producto_material | 3 |
| producto_reutilizable | 0 |
| producto_desechable | 0 |
| impacto_ambiental | 3 |

## 3. Pruebas de acciones referenciales

### Prueba 1. ON DELETE RESTRICT: categoría

**Operación intentada:**

```sql
DELETE FROM categoria WHERE id_categoria = 5;
```

**Resultado esperado:** PostgreSQL debe impedir eliminar una categoría que todavía tiene productos relacionados.

**Resultado observado:**

```text
ERROR: update or delete on table "categoria"
violates RESTRICT setting of foreign key constraint
"producto_id_categoria_fkey" on table "producto"

DETAIL: Key (id_categoria)=(5) is referenced from table "producto".
```

**Conteos:** productos asociados antes: 3; después: 3.

**Conclusión:** RESTRICT impidió eliminar la categoría y conservó los productos.

### Prueba 2. ON DELETE RESTRICT: fuente documental

**Operación intentada:**

```sql
DELETE FROM fuente WHERE id_fuente = 2;
```

**Resultado esperado:** impedir eliminar una fuente que respalda registros de impacto ambiental.

**Resultado observado:**

```text
ERROR: update or delete on table "fuente"
violates RESTRICT setting of foreign key constraint
"impacto_ambiental_id_fuente_fkey"
on table "impacto_ambiental"
```

**Conteos:** impactos asociados antes: 3; después: 3.

**Conclusión:** RESTRICT conservó la fuente y los registros ambientales respaldados por ella.

### Prueba 3. ON DELETE RESTRICT: producto

**Operación intentada:**

```sql
DELETE FROM producto WHERE id_producto = 4;
```

**Resultado esperado:** impedir eliminar un producto que tiene mediciones ambientales.

**Resultado observado:**

```text
ERROR: update or delete on table "producto"
violates RESTRICT setting of foreign key constraint
"impacto_ambiental_id_producto_fkey"
on table "impacto_ambiental"
```

**Conteos:** impactos asociados antes: 1; después: 1.

**Conclusión:** RESTRICT protegió el historial ambiental del producto.

### Prueba 4. ON DELETE SET NULL: país

**Operaciones realizadas:**

```sql
UPDATE producto
SET id_pais = 2
WHERE id_producto = 4;

DELETE FROM pais WHERE id_pais = 2;
```

**Resultado esperado:** eliminar el país y conservar el producto con `id_pais = NULL`.

**Resultado observado:**

```text
PRUEBA 4 CORRECTA: SET NULL elimino la referencia al pais
y conservo el producto.
Productos que referenciaban Mexico antes del borrado: 1.
```

**Conteos y resultado:** un producto referenciaba temporalmente al país México. Después del borrado, el producto permaneció y su clave de país quedó en NULL.

**Conclusión:** SET NULL permitió conservar el producto porque la relación con el país es opcional.

### Prueba 5. ON DELETE CASCADE: producto

Se creó temporalmente un producto reutilizable y una asociación con un material.

**Operación de eliminación:**

```sql
DELETE FROM producto
WHERE id_producto = :id_producto_temporal;
```

**Resultado esperado:** eliminar automáticamente las filas dependientes del producto.

**Resultado observado:**

```text
PRUEBA 5 CORRECTA: CASCADE elimino el producto y sus dependencias.
Subtipo antes/despues: 1/0.
Relaciones antes/despues: 1/0.
```

| Registro dependiente | Antes | Después |
|---|---:|---:|
| Producto reutilizable temporal | 1 | 0 |
| Relación producto-material temporal | 1 | 0 |

**Conclusión:** CASCADE eliminó las filas dependientes sin dejar asociaciones huérfanas.

### Prueba 6. ON DELETE CASCADE: material

**Operación intentada:**

```sql
DELETE FROM material WHERE id_material = 2;
```

**Resultado esperado:** eliminar las asociaciones del material, pero conservar el producto.

**Resultado observado:**

```text
PRUEBA 6 CORRECTA: CASCADE elimino las asociaciones del material.
Relaciones antes/despues: 1/0.
Producto conservado: 1.
```

**Conclusión:** CASCADE eliminó la relación de la tabla asociativa, sin eliminar el producto.

### Prueba 7. ON UPDATE CASCADE: categoría

Se actualizó temporalmente el identificador de la categoría 5 a un identificador nuevo.

**Operación realizada:**

```sql
UPDATE categoria
SET id_categoria = :nuevo_id
WHERE id_categoria = 5;
```

**Resultado observado:**

```text
PRUEBA 7 CORRECTA: ON UPDATE CASCADE traslado las referencias.
Antes: 3, con nueva clave: 3, con clave anterior: 0.
```

**Conclusión:** los tres productos conservaron su relación con la categoría después de actualizarse la clave primaria.

### Prueba 8. Clave foránea inexistente

**Operación intentada:**

```sql
INSERT INTO producto (nombre, id_categoria, id_pais)
VALUES (
    'Producto temporal con pais inexistente',
    (SELECT MIN(id_categoria) FROM categoria),
    9999999
);
```

**Resultado esperado:** PostgreSQL debe rechazar una clave de país que no existe.

**Mensaje observado:**

```text
insert or update on table "producto"
violates foreign key constraint
"producto_id_pais_fkey"
```

**Conclusión:** la clave foránea impidió registrar una referencia a un país inexistente.

### Prueba 9. Orden de carga: tabla hija antes que tabla padre

Primero se intentó crear una relación producto-material con un identificador de producto que todavía no existía.

**Primera operación:**

```sql
INSERT INTO producto_material (id_producto, id_material)
VALUES (:id_producto_nuevo, 2);
```

**Resultado observado:**

```text
PRUEBA 9A CORRECTA: el hijo fue rechazado antes de crear el padre.

insert or update on table "producto_material"
violates foreign key constraint
"producto_material_id_producto_fkey"
```

Después se insertó primero el producto y luego la relación:

```sql
INSERT INTO producto (nombre, id_categoria)
VALUES (
    'Producto temporal orden de carga',
    (SELECT MIN(id_categoria) FROM categoria)
);

INSERT INTO producto_material (id_producto, id_material)
VALUES (:id_producto_creado, 2);
```

**Resultado observado:**

```text
PRUEBA 9B CORRECTA: despues de crear el padre,
se inserto la relacion hija.
```

**Conclusión:** la carga debe respetar las dependencias. Primero se registran las entidades padre y después sus registros hijos.

## 4. Verificación del ROLLBACK

La ejecución terminó con:

```text
ROLLBACK
FIN: las pruebas terminaron y todos los cambios temporales fueron revertidos.
```

Después de la reversión se volvieron a consultar las nueve tablas.

| Tabla | Antes | Después |
|---|---:|---:|
| categoria | 3 | 3 |
| pais | 1 | 1 |
| material | 4 | 4 |
| fuente | 3 | 3 |
| producto | 3 | 3 |
| producto_material | 3 | 3 |
| producto_reutilizable | 0 | 0 |
| producto_desechable | 0 | 0 |
| impacto_ambiental | 3 | 3 |

Los conteos son iguales, lo que demuestra que las modificaciones temporales fueron revertidas.

## 5. Orden correcto de carga

La prueba de la relación muchos a muchos mostró que no se puede registrar una fila en `producto_material` si todavía no existe el producto referenciado.

El orden recomendado para cargar EcoData es:

1. `categoria`, `pais`, `material` y `fuente`.
2. `producto`.
3. `producto_reutilizable` y `producto_desechable`.
4. `producto_material`.
5. `impacto_ambiental`.

Este orden respeta las dependencias de las claves foráneas y evita errores de integridad referencial.

## 6. Conclusión

Las pruebas demostraron que las acciones referenciales seleccionadas para EcoData funcionan de acuerdo con las reglas del dominio.

RESTRICT protegió las categorías, fuentes y productos que tienen información dependiente. SET NULL permitió conservar un producto sin país de fabricación. CASCADE eliminó las filas dependientes de productos y materiales, mientras que ON UPDATE CASCADE mantuvo las referencias después de modificar una clave padre.

También se comprobó que PostgreSQL rechaza claves foráneas inexistentes y que las tablas hijas deben cargarse después de sus respectivas tablas padre.

Finalmente, el ROLLBACK permitió comprobar que los cambios de prueba no modificaron permanentemente los registros de la copia de trabajo.

## 7. Comprobaciones generales de integridad en las dos bases

Se creó el archivo `sql/003-verificacion-integridad.sql`, que realiza tres revisiones de solo lectura sobre los esquemas `public` y `warehouse`.

### 7.1 Claves foráneas huérfanas

Se recorrieron las claves foráneas declaradas y se comprobó que cada referencia no nula tuviera un registro padre existente.

| Base de datos | Registros huérfanos |
|---|---:|
| ecodata | 0 |
| obras_publicas | 0 |

Resultado observado en ambas bases:

```text
CORRECTO: no se encontraron claves foraneas huerfanas.
```

### 7.2 Duplicados en claves primarias y UNIQUE

Se revisaron las restricciones de clave primaria y unicidad simple y compuesta.

| Base de datos | Grupos duplicados |
|---|---:|
| ecodata | 0 |
| obras_publicas | 0 |

Resultado observado:

```text
CORRECTO: no se encontraron duplicados en PK y UNIQUE.
```

### 7.3 Valores nulos en columnas NOT NULL

Se recorrieron las columnas declaradas como obligatorias en las tablas de ambos esquemas.

| Base de datos | Valores nulos prohibidos |
|---|---:|
| ecodata | 0 |
| obras_publicas | 0 |

Resultado observado:

```text
CORRECTO: no se encontraron nulos en columnas NOT NULL.
```

### 7.4 Archivo SQL y ejecución

El archivo utilizado fue:

`practica5/sql/003-verificacion-integridad.sql`

Se ejecutó en las dos bases:

```powershell
Get-Content .\practica5\sql\003-verificacion-integridad.sql -Raw |
    docker exec -i practica1 psql -v ON_ERROR_STOP=1 -U lis -d ecodata

Get-Content .\practica5\sql\003-verificacion-integridad.sql -Raw |
    docker exec -i obras-publicas-db-1 psql -v ON_ERROR_STOP=1 -U obras -d obras_publicas
```

Las dos ejecuciones finalizaron con:

```text
FIN: verificaciones de integridad terminadas.
```

### 7.5 Conclusión

Las comprobaciones no encontraron referencias huérfanas, grupos duplicados en claves primarias o únicas, ni valores nulos en columnas obligatorias de las dos bases.

Esto indica que, en el momento de la revisión, las restricciones declaradas protegen correctamente la integridad referencial y los dominios de unicidad y obligatoriedad. Las consultas no modificaron los datos.
