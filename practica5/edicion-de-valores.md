# Ejercicio 2.4. Edición de valores y transacciones

**Proyecto:** EcoData  
**Gestor:** PostgreSQL  
**Base utilizada para las pruebas:** `ecodata_pruebas`  
**Fecha:** 6 de noviembre de 2026

## 1. Objetivo

Aplicar sentencias DML para insertar, actualizar y eliminar información de EcoData, utilizando consultas, subconsultas, condiciones y transacciones.

Las operaciones se realizaron en una copia de la base original para conservar los registros de `ecodata`.

## 2. INSERT con consulta e inserción que resuelve duplicados

### 2.1 INSERT que obtiene valores de una consulta

Se utilizó una consulta sobre la tabla `categoria` para obtener el identificador de la categoría de productos reutilizables.

```sql
INSERT INTO producto
    (nombre, marca, vida_util, id_categoria, id_pais)
SELECT
    'Botella reutilizable de acero inoxidable 750 ml - prueba',
    'EcoData',
    '5 años',
    c.id_categoria,
    NULL
FROM categoria c
WHERE c.id_categoria = 6
ON CONFLICT (nombre, id_categoria) DO NOTHING
RETURNING id_producto, nombre, id_categoria;
```

**Resultado observado:** PostgreSQL insertó el producto temporal con identificador 13.

### 2.2 INSERT que resuelve duplicados

Se ejecutó nuevamente la misma inserción utilizando `ON CONFLICT DO NOTHING`.

```sql
INSERT INTO producto
    (nombre, marca, vida_util, id_categoria, id_pais)
SELECT
    'Botella reutilizable de acero inoxidable 750 ml - prueba',
    'EcoData',
    '5 años',
    c.id_categoria,
    NULL
FROM categoria c
WHERE c.id_categoria = 6
ON CONFLICT (nombre, id_categoria) DO NOTHING;
```

**Resultado observado:**

```text
INSERT 0 0
```

No se generó un segundo producto porque ya existía la combinación de nombre y categoría.

También se utilizó `ON CONFLICT DO NOTHING` en `producto_material`, cuya clave primaria es compuesta, para impedir repetir la misma asociación entre producto y material.

**Conclusión:** las inserciones pueden repetirse sin crear duplicados cuando se utiliza una regla de conflicto respaldada por una restricción UNIQUE o una clave primaria.

## 3. UPDATE dependiente de otra tabla y clasificación con CASE

### 3.1 UPDATE utilizando otra tabla

Se actualizó la vida útil del producto temporal tomando como referencia su categoría.

```sql
UPDATE producto p
SET vida_util = '5 años'
FROM categoria c
WHERE p.id_categoria = c.id_categoria
  AND c.nombre = 'Productos reutilizables'
  AND p.nombre =
      'Botella reutilizable de acero inoxidable 750 ml - prueba'
RETURNING p.id_producto, p.nombre, c.nombre AS categoria, p.vida_util;
```

**Resultado observado:** PostgreSQL actualizó un registro (`UPDATE 1`). La consulta mostró la categoría `Productos reutilizables` y la vida útil `5 años`.

### 3.2 UPDATE utilizando CASE

Se clasificaron los impactos ambientales de acuerdo con las emisiones de CO2.

```sql
UPDATE impacto_ambiental
SET nivel_impacto =
    CASE
        WHEN emisiones_co2 <= 0.15
            THEN 'Bajo (caso nacional)'
        WHEN emisiones_co2 <= 0.50
            THEN 'Medio (caso nacional)'
        ELSE 'Alto (caso nacional)'
    END
WHERE emisiones_co2 IS NOT NULL;
```

**Resultado observado:**

| ID impacto | Emisiones CO2 | Nivel asignado |
|---:|---:|---|
| 1 | 0.095000 | Bajo (caso nacional) |
| 2 | 0.813000 | Alto (caso nacional) |
| 3 | 0.301000 | Medio (caso nacional) |

Se actualizaron tres registros.

**Conclusión:** `UPDATE ... FROM` permitió utilizar información de otra tabla y `CASE` facilitó clasificar los registros con condiciones diferentes.

## 4. DELETE con subconsulta y borrado lógico

### 4.1 DELETE con subconsulta

Se eliminó el producto temporal relacionado con el material acero inoxidable.

```sql
DELETE FROM producto
WHERE nombre =
    'Botella reutilizable de acero inoxidable 750 ml - prueba'
  AND id_producto IN (
      SELECT pm.id_producto
      FROM producto_material pm
      WHERE pm.id_material = 5
  )
RETURNING id_producto, nombre;
```

**Resultado observado:** `DELETE 1`.

La acción CASCADE eliminó automáticamente la relación correspondiente en `producto_material`.

**Justificación:** el borrado físico se utiliza cuando el registro temporal ya no debe conservarse. Las acciones referenciales evitan dejar asociaciones sin su producto padre.

### 4.2 Borrado lógico

Se agregó la columna `activo` mediante la migración:

`practica5/sql/004-borrado-logico.sql`

La columna tiene tipo BOOLEAN, es obligatoria y utiliza `TRUE` como valor predeterminado.

```sql
ALTER TABLE public.producto
ADD COLUMN activo BOOLEAN NOT NULL DEFAULT TRUE;
```

Se marcó temporalmente el producto 6 como inactivo:

```sql
UPDATE producto
SET activo = FALSE
WHERE id_producto = 6
RETURNING id_producto, nombre, activo;
```

Resultado observado:

```text
id_producto: 6
nombre: Lata de aluminio para refresco de 355 ml
activo: f
```

Después se restauró su estado:

```sql
UPDATE producto
SET activo = TRUE
WHERE id_producto = 6;
```

**Justificación:** el borrado lógico conserva físicamente el registro y sus relaciones. Es útil cuando se necesita mantener el historial de un producto o evitar perder información relacionada. El borrado físico, en cambio, elimina el registro y puede activar acciones referenciales como CASCADE.

La columna `activo` se agregó únicamente en `ecodata_pruebas`; la base original no fue modificada.

## 5. Transacción con SAVEPOINT, reversión parcial y COMMIT

Se realizó una transacción que involucró las tablas `producto`, `producto_material`, `impacto_ambiental` y `producto_reutilizable`.

### 5.1 Crear el producto y su material

```sql
BEGIN;

INSERT INTO producto (nombre, marca, vida_util, id_categoria)
SELECT
    'Kit transaccional EcoData - ejercicio 2.4',
    'EcoData',
    '3 años',
    id_categoria
FROM categoria
WHERE id_categoria = 6
ON CONFLICT (nombre, id_categoria) DO NOTHING;

INSERT INTO producto_material (id_producto, id_material)
SELECT p.id_producto, 5
FROM producto p
WHERE p.nombre =
    'Kit transaccional EcoData - ejercicio 2.4'
ON CONFLICT (id_producto, id_material) DO NOTHING;
```

### 5.2 Crear el punto de recuperación

```sql
SAVEPOINT antes_de_impacto;
```

Se intentó insertar un impacto ambiental para el producto temporal.

```sql
INSERT INTO impacto_ambiental
    (id_producto, id_fuente, consumo_agua,
     consumo_energia, emisiones_co2, residuos_generados,
     nivel_impacto, fecha_dato)
SELECT
    p.id_producto,
    2,
    10.00,
    2.50,
    0.065000,
    0.20,
    'Bajo (caso nacional)',
    CURRENT_DATE
FROM producto p
WHERE p.nombre =
    'Kit transaccional EcoData - ejercicio 2.4';
```

### 5.3 Reversión parcial

Se ejecutó:

```sql
ROLLBACK TO SAVEPOINT antes_de_impacto;
```

Esto revirtió solamente la inserción del impacto ambiental. El producto y su asociación con el material permanecieron dentro de la transacción.

Después se registró su especialización:

```sql
INSERT INTO producto_reutilizable
    (id_producto, numero_reutilizaciones, requiere_mantenimiento)
SELECT id_producto, 100, TRUE
FROM producto
WHERE nombre =
    'Kit transaccional EcoData - ejercicio 2.4'
ON CONFLICT (id_producto) DO NOTHING;
```

### 5.4 Confirmación final

```sql
COMMIT;
```

**Resultado observado:**

| Elemento del producto temporal | Resultado |
|---|---:|
| Producto creado | 1 |
| Relación con material | 1 |
| Subtipo reutilizable | 1 |
| Impactos ambientales nuevos | 0 |

La consulta final mostró:

```text
materiales: 1
subtipos_reutilizables: 1
impactos: 0
```

El COMMIT confirmó los cambios que no habían sido revertidos por el SAVEPOINT.

Para limpiar el registro de demostración, se ejecutó un DELETE en una transacción independiente. La eliminación física del producto activó CASCADE en sus relaciones y subtipo.

## 6. Transacción fallida por una restricción

Para comprobar que PostgreSQL revierte todas las operaciones de una transacción cuando ocurre un error, se ejecutó un cambio de precio y posteriormente se intentó registrar emisiones negativas.

### 6.1 Operación inicial

```sql
BEGIN;

UPDATE producto
SET precio_aproximado = 123.45
WHERE id_producto = 4
RETURNING id_producto, nombre, precio_aproximado;
```

PostgreSQL permitió el cambio temporal del precio.

### 6.2 Operación que produjo el error

```sql
UPDATE impacto_ambiental
SET emisiones_co2 = -1
WHERE id_impacto = 1;
```

**Mensaje observado:**

```text
ERROR: new row for relation "impacto_ambiental"
violates check constraint "chk_impacto_co2_no_negativo"
```

La regla CHECK impide registrar emisiones de CO2 negativas.

Al intentar confirmar la transacción, PostgreSQL ejecutó su reversión:

```text
ROLLBACK
```

### 6.3 Verificación de la reversión

Se consultaron los registros después del error:

```sql
SELECT id_producto, precio_aproximado
FROM producto
WHERE id_producto = 4;

SELECT id_impacto, emisiones_co2
FROM impacto_ambiental
WHERE id_impacto = 1;
```

**Resultados observados:**

| Registro | Valor después del ROLLBACK |
|---|---:|
| Precio aproximado del producto 4 | NULL |
| Emisiones de CO2 del impacto 1 | 0.095000 |

El precio volvió a su estado original, aunque su modificación había ocurrido antes del error. También se conservó el valor original de emisiones.

**Conclusión:** PostgreSQL garantizó la propiedad de atomicidad: si una operación falla dentro de la transacción, los cambios previos de esa misma transacción no quedan confirmados.

## 7. Archivos ejecutables y migraciones

| Archivo | Función |
|---|---|
| `sql/004-borrado-logico.sql` | Agrega la columna `activo` en la copia de pruebas. |
| `sql/005-edicion-transacciones.sql` | Ejecuta las operaciones DML, las transacciones y el SAVEPOINT. |
| `sql/006-transaccion-fallida.sql` | Comprueba la reversión de una transacción que viola un CHECK. |

Las pruebas se ejecutaron en `ecodata_pruebas`, conservando la base original `ecodata`.

## 8. Conclusión general

En este ejercicio se aplicaron diferentes operaciones DML utilizando información del proyecto EcoData. Las inserciones permitieron evitar duplicados, las actualizaciones utilizaron consultas relacionadas y condiciones CASE, y las eliminaciones demostraron la diferencia entre borrar físicamente y dar de baja un producto de forma lógica.

También se comprobó el funcionamiento de las transacciones mediante SAVEPOINT, ROLLBACK TO SAVEPOINT y COMMIT. Finalmente, una operación inválida provocó que PostgreSQL revirtiera toda la transacción, incluso el cambio que se había ejecutado correctamente antes del error.

Estas pruebas permitieron observar cómo las restricciones y las transacciones ayudan a conservar la consistencia de la información y a evitar modificaciones parciales cuando ocurre un problema.
