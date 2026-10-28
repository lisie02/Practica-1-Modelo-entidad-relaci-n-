# Ejercicio 3. Reglas de transformación básicas

## Proyecto EcoData: Impacto ambiental de productos cotidianos

### 1. Objetivo

Documentar las reglas utilizadas para transformar el modelo Entidad-Relación Extendido (EER) de EcoData en un modelo relacional, conservando las entidades, atributos, claves y restricciones necesarias para mantener la integridad de la información.

### 2. Regla 1. Transformación de entidades fuertes

Cada entidad fuerte del modelo EER se convierte en una tabla. Su identificador se establece como clave primaria y sus atributos simples se convierten en columnas.

| Entidad EER | Tabla relacional | Clave primaria |
|---|---|---|
| Categoría | `categoria` | `id_categoria` |
| Producto | `producto` | `id_producto` |
| País | `pais` | `id_pais` |
| Material | `material` | `id_material` |
| Impacto ambiental | `impacto_ambiental` | `id_impacto` |
| Fuente | `fuente` | `id_fuente` |

### 3. Restricciones

- Las claves primarias identifican de manera única cada registro.
- Los atributos obligatorios se declaran con `NOT NULL`.
- Las claves foráneas mantienen la integridad referencial entre las tablas.
- Los tipos de datos se seleccionan según la información almacenada.

### 4. Regla 2. Atributos compuestos

El atributo `vida_util` de Producto debe revisarse para determinar si en el modelo aprobado está compuesto por cantidad y unidad.

Si se confirma que es compuesto, se sustituirá por dos columnas, por ejemplo, `vida_util_cantidad` y `vida_util_unidad`. Si el modelo aprobado lo considera un atributo simple, se conservará como una sola columna.

### 5. Regla 3. Atributos multivaluados

El modelo deberá revisarse para identificar atributos multivaluados. Si se conserva el atributo `certificaciones_ambientales` como multivaluado, se creará una tabla adicional que incluya `id_producto` como clave foránea y el valor de cada certificación.

La clave primaria de esa tabla será la combinación de `id_producto` y `certificacion`, para evitar registrar dos veces la misma certificación para un producto.

### 6. Verificación

La transformación se comprobará comparando las entidades y atributos del inventario EER con las tablas y columnas creadas en PostgreSQL. Cualquier diferencia deberá justificarse y documentarse.

---

## Ejercicio 5. Transformación de la jerarquía ISA

### 1. Jerarquía del modelo EER

En EcoData, la entidad general `PRODUCTO` se especializa en dos subtipos:

- `PRODUCTO_REUTILIZABLE`: contiene los atributos `numero_reutilizaciones` y `requiere_mantenimiento`.
- `PRODUCTO_DESECHABLE`: contiene los atributos `tiempo_descomposicion_anios` y `genera_residuos`.

### 2. Estrategia de transformación

Se eligió conservar una tabla para la entidad general y una tabla independiente para cada subtipo.

| Tabla | Clave primaria | Clave foránea |
|---|---|---|
| `producto` | `id_producto` | `id_categoria`, `id_pais` |
| `producto_reutilizable` | `id_producto` | `id_producto` → `producto(id_producto)` |
| `producto_desechable` | `id_producto` | `id_producto` → `producto(id_producto)` |

Esta estrategia permite almacenar los atributos comunes en `producto` y los atributos específicos en la tabla correspondiente a cada subtipo.

### 3. Restricciones de la jerarquía

La jerarquía se definió como disjunta y parcial:

- **Disyunción:** un producto no debería pertenecer simultáneamente a `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE`.
- **Completitud parcial:** un producto puede existir en `PRODUCTO` sin pertenecer todavía a alguno de los subtipos.

Las claves primarias y foráneas garantizan que cada registro de un subtipo corresponda a un producto existente. Sin embargo, por sí solas no impiden que un producto aparezca en ambos subtipos; para garantizar la disyunción se necesita una restricción adicional.

### 4. Comprobación en PostgreSQL

Se revisaron las estructuras de `producto_reutilizable` y `producto_desechable` mediante el comando `\d`. En ambas tablas, `id_producto` está definido como clave primaria y clave foránea hacia `producto`.

**Resultado:** la estructura de las tablas y la referencia hacia la entidad general fueron verificadas. La exclusividad entre subtipos queda pendiente de una comprobación o restricción adicional.


---

## Ejercicio 6. Revisión de atributos especiales y restricciones

### 1. Atributo vida_util

En la tabla `producto`, el atributo `vida_util` se implementó como `INT`. Esta decisión corresponde a un atributo simple que almacena una cantidad entera.

Si el modelo EER aprobado lo define como compuesto por cantidad y unidad, será necesario sustituirlo por dos columnas, por ejemplo, `vida_util_cantidad` y `vida_util_unidad`. Esta modificación se realizará únicamente si corresponde al modelo original entregado.

### 2. Atributos multivaluados

El SQL actual no contiene una tabla para `certificaciones_ambientales`. Si este atributo forma parte del modelo EER aprobado como multivaluado, deberá crearse una tabla adicional con una clave foránea hacia `producto`.

Si el atributo no pertenece al modelo aprobado, no será necesario añadir dicha tabla.

### 3. Atributo nivel_impacto

En `impacto_ambiental`, `nivel_impacto` está definido como `VARCHAR(50)` y se almacena directamente. El SQL actual no contiene una regla que lo calcule a partir de las métricas ambientales.

Si el modelo lo define como derivado, deberá documentarse la fórmula de cálculo y decidir si se obtiene mediante una consulta, una vista o una expresión implementada en la base de datos.

### 4. Restricción de disyunción ISA

Las tablas `producto_reutilizable` y `producto_desechable` comparten la clave `id_producto`, que referencia a `producto`. Sin embargo, las claves foráneas actuales no impiden que el mismo producto aparezca en ambos subtipos.

Si la jerarquía aprobada es disjunta, deberá implementarse una restricción adicional para garantizar que un producto no pertenezca simultáneamente a ambos subtipos.

### 5. Resultado de la revisión

Se verificaron las tablas, las claves primarias, las claves foráneas y la clave primaria compuesta de `producto_material`. Los atributos especiales y la restricción de disyunción quedan sujetos a la comparación final con el modelo EER aprobado antes de realizar cambios en el SQL.
