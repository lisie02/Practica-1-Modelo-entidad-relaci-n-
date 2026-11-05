# Ejercicio 1.5. Pruebas de restricciones de dominio

**Proyecto:** EcoData  
**Gestor:** PostgreSQL  
**Base de datos:** ecodata  
**Fecha de ejecución:** 5 de noviembre de 2026

## 1. Objetivo

Comprobar que las restricciones de integridad y dominio de EcoData impiden registrar valores incorrectos, duplicados o incompatibles con las reglas del proyecto.

Se realizaron diez pruebas dentro de una transacción. Al terminar se ejecutó ROLLBACK para revertir los cambios temporales.

## 2. Casos de prueba

### Prueba 1. NOT NULL: nombre del producto

**Operación intentada:**

```sql
INSERT INTO producto (nombre, id_categoria)
VALUES (NULL, (SELECT MIN(id_categoria) FROM categoria));
```

**Resultado esperado:** PostgreSQL debe rechazar la inserción porque el nombre del producto es obligatorio.

**Mensaje observado:**

```text
null value in column "nombre" of relation "producto"
violates not-null constraint
```

**Regla protegida:** el atributo `producto.nombre` debe tener un valor.

**Resultado:** Correcto. La inserción fue rechazada.

### Prueba 2. DEFAULT: fecha de consulta automática

**Operación intentada:**

```sql
INSERT INTO fuente (nombre, tipo, url)
VALUES (
    'Fuente temporal para prueba DEFAULT',
    'Prueba',
    'https://example.org/eco-prueba-default'
)
RETURNING fecha_consulta;
```

**Resultado esperado:** si se omite la fecha de consulta, PostgreSQL debe asignar la fecha actual.

**Mensaje observado:**

```text
PRUEBA 2 CORRECTA: DEFAULT asigno la fecha actual (2026-11-05).
```

**Regla protegida:** toda nueva fuente que omita `fecha_consulta` recibe automáticamente la fecha de registro.

**Resultado:** Correcto. Se asignó `2026-11-05`.

### Prueba 3. UNIQUE simple: nombre del material

**Operación intentada:**

```sql
INSERT INTO material (nombre)
SELECT nombre FROM material LIMIT 1;
```

**Resultado esperado:** PostgreSQL debe rechazar un material con un nombre que ya existe.

**Mensaje observado:**

```text
duplicate key value violates unique constraint "uq_material_nombre"
```

**Regla protegida:** `material.nombre` no puede repetirse.

**Resultado:** Correcto. El duplicado fue rechazado.

### Prueba 4. UNIQUE simple: URL de la fuente

**Operación intentada:** insertar una fuente utilizando una URL que ya está registrada.

**Resultado esperado:** PostgreSQL debe impedir que se registre dos veces la misma URL.

**Mensaje observado:**

```text
duplicate key value violates unique constraint "uq_fuente_url"
```

**Regla protegida:** `fuente.url` debe ser única cuando contiene un valor.

**Resultado:** Correcto. La URL duplicada fue rechazada.

### Prueba 5. UNIQUE compuesta: producto y categoría

**Operación intentada:** insertar un producto con el mismo nombre y la misma categoría de otro producto existente.

**Resultado esperado:** PostgreSQL debe impedir la repetición de la combinación.

**Mensaje observado:**

```text
duplicate key value violates unique constraint "uq_producto_nombre_categoria"
```

**Regla protegida:** la combinación `(nombre, id_categoria)` debe ser única.

**Resultado:** Correcto. La combinación duplicada fue rechazada.

### Prueba 6. PRIMARY KEY compuesta: producto y material

**Operación intentada:** insertar nuevamente una relación existente de `producto_material`.

**Resultado esperado:** PostgreSQL debe impedir que se repita la misma pareja de identificadores.

**Mensaje observado:**

```text
duplicate key value violates unique constraint "producto_material_pkey"
```

**Regla protegida:** la combinación `(id_producto, id_material)` constituye la clave primaria compuesta.

**Resultado:** Correcto. La relación repetida fue rechazada.

### Prueba 7. CHECK de rango: precio negativo

**Operación intentada:**

```sql
INSERT INTO producto (nombre, precio_aproximado, id_categoria)
VALUES (
    'Producto temporal para prueba de precio',
    -1,
    (SELECT MIN(id_categoria) FROM categoria)
);
```

**Resultado esperado:** PostgreSQL debe rechazar un precio inferior a cero.

**Mensaje observado:**

```text
new row for relation "producto" violates check constraint
"chk_producto_precio_no_negativo"
```

**Regla protegida:** `precio_aproximado` no puede ser negativo.

**Resultado:** Correcto. El precio negativo fue rechazado.

### Prueba 8. CHECK de rango: emisiones negativas

**Operación intentada:** actualizar un registro ambiental asignando `-1` a `emisiones_co2`.

**Resultado esperado:** PostgreSQL debe impedir que una medición ambiental tenga emisiones negativas.

**Mensaje observado:**

```text
new row for relation "impacto_ambiental" violates check constraint
"chk_impacto_co2_no_negativo"
```

**Regla protegida:** las emisiones de CO2 equivalente deben ser iguales o mayores que cero.

**Resultado:** Correcto. El valor negativo fue rechazado.

### Prueba 9. CHECK de formato: URL incorrecta

**Operación intentada:**

```sql
INSERT INTO fuente (nombre, tipo, url)
VALUES (
    'Fuente temporal con URL incorrecta',
    'Prueba',
    'ftp://direccion-no-permitida'
);
```

**Resultado esperado:** PostgreSQL debe rechazar direcciones que no utilicen HTTP o HTTPS.

**Mensaje observado:**

```text
new row for relation "fuente" violates check constraint
"chk_fuente_url_formato"
```

**Regla protegida:** `fuente.url` debe cumplir el formato permitido.

**Resultado:** Correcto. La URL incorrecta fue rechazada.

### Prueba 10. CHECK entre columnas: nivel de impacto sin emisiones

**Operación intentada:** asignar un nivel de impacto y establecer las emisiones de CO2 en NULL.

**Resultado esperado:** PostgreSQL debe impedir que exista una clasificación de impacto sin el dato de emisiones correspondiente.

**Mensaje observado:**

```text
new row for relation "impacto_ambiental" violates check constraint
"chk_nivel_requiere_emisiones"
```

**Regla protegida:** si `nivel_impacto` tiene un valor, `emisiones_co2` no puede ser NULL.

**Resultado:** Correcto. La modificación fue rechazada.

## 3. Reversión de las pruebas

Las diez pruebas se ejecutaron dentro de una transacción:

```sql
BEGIN;
-- Diez casos de prueba.
ROLLBACK;
```

Al finalizar, PostgreSQL mostró:

```text
ROLLBACK
```

La prueba de DEFAULT insertó temporalmente una fuente para recuperar su fecha automática. La reversión final eliminó ese registro de prueba.

Las operaciones rechazadas fueron controladas mediante bloques PL/pgSQL con manejo de excepciones, por lo que cada error pudo comprobarse sin interrumpir las demás pruebas.

## 4. Conclusión

Las diez pruebas permitieron comprobar el funcionamiento de las restricciones de EcoData. PostgreSQL rechazó los valores nulos no permitidos, los duplicados, los precios negativos, las emisiones negativas, las URL con formato incorrecto y las combinaciones de datos incompatibles.

También se comprobó el funcionamiento del valor DEFAULT para la fecha de consulta.

Finalmente, el ROLLBACK permitió revertir los cambios temporales y conservar la información permanente de la base de datos.
