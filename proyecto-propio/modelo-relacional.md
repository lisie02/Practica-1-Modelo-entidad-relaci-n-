# Modelo relacional de EcoData

## 1. Introducción

En este documento se presenta la transformación del modelo Entidad-Relación Extendido (EER) del proyecto EcoData al modelo relacional. Para realizarla se toma como referencia el inventario de entidades, atributos, relaciones, claves primarias, claves foráneas y jerarquías elaborado en el ejercicio 2 de la Práctica 3.

El objetivo es representar la información del proyecto mediante tablas relacionadas entre sí, conservando las reglas de integridad del modelo original.

## 2. Esquema relacional

### CATEGORIA
- **Clave primaria:** `id_categoria`
- **Atributos:** `nombre`, `descripcion`

### PAIS
- **Clave primaria:** `id_pais`
- **Atributos:** `nombre`

### PRODUCTO
- **Clave primaria:** `id_producto`
- **Claves foráneas:**
  - `id_categoria` → `CATEGORIA(id_categoria)`
  - `id_pais` → `PAIS(id_pais)`
- **Atributos:** `nombre`, `marca`, `precio_aproximado`, `vida_util`

### MATERIAL
- **Clave primaria:** `id_material`
- **Atributos:** `nombre`, `descripcion`, `tipo`, `reciclable`

### FUENTE
- **Clave primaria:** `id_fuente`
- **Atributos:** `nombre`, `tipo`, `url`, `fecha_consulta`

### PRODUCTO_MATERIAL
- **Clave primaria compuesta:** (`id_producto`, `id_material`)
- **Claves foráneas:**
  - `id_producto` → `PRODUCTO(id_producto)`
  - `id_material` → `MATERIAL(id_material)`

Esta tabla resuelve la relación de muchos a muchos entre productos y materiales.

### IMPACTO_AMBIENTAL
- **Clave primaria:** `id_impacto`
- **Claves foráneas:**
  - `id_producto` → `PRODUCTO(id_producto)`
  - `id_fuente` → `FUENTE(id_fuente)`
- **Atributos:** `consumo_agua`, `consumo_energia`, `emisiones_co2`, `residuos_generados`, `nivel_impacto`, `fecha_dato`

### PRODUCTO_REUTILIZABLE
- **Clave primaria y foránea:** `id_producto` → `PRODUCTO(id_producto)`
- **Atributos:** `numero_reutilizaciones`, `requiere_mantenimiento`

### PRODUCTO_DESECHABLE
- **Clave primaria y foránea:** `id_producto` → `PRODUCTO(id_producto)`
- **Atributos:** `tiempo_descomposicion_anios`, `genera_residuos`

## 3. Reglas de transformación

1. Cada entidad fuerte se representa mediante una tabla.
2. Las relaciones de uno a muchos se implementan colocando una clave foránea en la tabla del lado muchos.
3. La relación de muchos a muchos entre `PRODUCTO` y `MATERIAL` se implementa mediante `PRODUCTO_MATERIAL`.
4. La jerarquía ISA se representa con una tabla para `PRODUCTO` y una tabla independiente para cada subtipo.
5. `id_producto` funciona como clave primaria y foránea en las tablas de los subtipos.
6. No se crea una tabla para `certificaciones_ambientales` porque este atributo no aparece en el diagrama EER entregado.
7. `vida_util` se conserva como atributo simple, ya que así aparece en el diagrama original. Si el equipo decide dividirlo en cantidad y unidad, deberá actualizar primero el modelo EER y documentar el cambio.

## 4. Verificación previa

Antes de implementar el esquema en SQL, se debe comprobar que:
- Todas las entidades del inventario estén representadas.
- Todas las claves primarias estén definidas.
- Las claves foráneas hagan referencia a tablas existentes.
- La tabla `PRODUCTO_MATERIAL` conserve su clave primaria compuesta.
- La jerarquía ISA conserve las restricciones de disyunción y completitud acordadas por el equipo.
- No se hayan añadido atributos o entidades que no estén aprobados en el modelo EER.

---

## Ejercicio 4. Transformación de relaciones

### 1. Relaciones de uno a muchos (1:N)

En una relación de uno a muchos, la clave primaria de la entidad que se encuentra en el lado 1 se incorpora como clave foránea en la tabla que se encuentra en el lado N.

| Relación EER | Tabla que recibe la clave foránea | Clave foránea |
|---|---|---|
| CATEGORIA — PRODUCTO | `producto` | `id_categoria` |
| PAIS — PRODUCTO | `producto` | `id_pais` |
| PRODUCTO — IMPACTO_AMBIENTAL | `impacto_ambiental` | `id_producto` |
| FUENTE — IMPACTO_AMBIENTAL | `impacto_ambiental` | `id_fuente` |

Estas claves permiten relacionar cada producto con su categoría y país, así como cada registro de impacto ambiental con el producto analizado y la fuente de información correspondiente.

### 2. Relaciones de muchos a muchos (N:M)

La relación entre PRODUCTO y MATERIAL se transforma mediante una tabla intermedia llamada `producto_material`.

Esta tabla contiene:

- `id_producto`: clave foránea hacia `producto`.
- `id_material`: clave foránea hacia `material`.

La clave primaria es compuesta por `(id_producto, id_material)`. De esta manera, un producto puede utilizar varios materiales y un material puede formar parte de distintos productos, sin repetir la misma combinación.

### 3. Relaciones de identificación de los subtipos

Las tablas `producto_reutilizable` y `producto_desechable` representan la especialización de PRODUCTO.

En ambas tablas, `id_producto` funciona como clave primaria y clave foránea hacia `producto(id_producto)`. Esto permite que cada registro de un subtipo corresponda a un producto existente.

### 4. Comprobación en PostgreSQL

Las relaciones se verificaron consultando las restricciones de tipo `FOREIGN KEY` en el esquema `public`. También se comprobó que la tabla `producto_material` rechaza combinaciones duplicadas de producto y material.

La estructura de las claves foráneas quedó registrada en las pruebas de integridad de EcoData.

