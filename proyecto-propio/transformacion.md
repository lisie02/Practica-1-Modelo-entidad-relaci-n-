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
