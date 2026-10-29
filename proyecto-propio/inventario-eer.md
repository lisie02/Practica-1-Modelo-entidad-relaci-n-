# Ejercicio 2. Inventario del modelo EER del proyecto propio

## Proyecto EcoData: Impacto ambiental de productos cotidianos

### 1. Objetivo del inventario

El objetivo de este inventario es identificar y documentar todos los elementos del modelo Entidad-Relación Extendido (EER) del proyecto EcoData. Este documento servirá como una lista de verificación para comprobar que las entidades, los atributos, las relaciones y las restricciones del modelo original se conserven durante su transformación al modelo relacional.

El proyecto busca almacenar y organizar información sobre productos cotidianos y su impacto ambiental, considerando los materiales utilizados, el consumo de agua y energía, las emisiones de CO₂, la generación de residuos y las fuentes de información.

---

## 2. Entidades fuertes

Las entidades fuertes cuentan con una clave primaria propia que permite identificar cada registro de manera única.

| Entidad | Clave primaria | Atributos |
|---|---|---|
| **CATEGORIA** | `id_categoria` | `nombre`, `descripcion` |
| **PRODUCTO** | `id_producto` | `nombre`, `marca`, `precio_aproximado`, `vida_util`, `id_categoria`, `id_pais` |
| **PAIS** | `id_pais` | `nombre` |
| **MATERIAL** | `id_material` | `nombre`, `descripcion`, `tipo`, `reciclable` |
| **IMPACTO_AMBIENTAL** | `id_impacto` | `consumo_agua`, `consumo_energia`, `emisiones_co2`, `residuos_generados`, `nivel_impacto`, `fecha_dato`, `id_fuente` |
| **FUENTE** | `id_fuente` | `nombre`, `tipo`, `url`, `fecha_consulta` |

**Observación:** `id_categoria`, `id_pais` e `id_fuente` aparecen como claves foráneas en las entidades correspondientes. Se documentan aquí para mantener la correspondencia con el diagrama entregado.

---

## 3. Entidades débiles y entidades asociativas

### 3.1. PRODUCTO_MATERIAL

`PRODUCTO_MATERIAL` representa la asociación entre los productos y los materiales que los componen. Permite resolver la relación de muchos a muchos entre `PRODUCTO` y `MATERIAL`.

- **Clave primaria compuesta:** (`id_producto`, `id_material`).
- `id_producto` es clave foránea que referencia a `PRODUCTO(id_producto)`.
- `id_material` es clave foránea que referencia a `MATERIAL(id_material)`.

Esta entidad depende de la existencia de un producto y de un material. En el modelo relacional se implementará como una tabla asociativa con ambas claves.

**Nota de modelado:** en el diagrama se representa como entidad asociativa. Se considera débil en el sentido de que no tiene una identificación independiente de sus entidades participantes.

### 3.2. EVIDENCIA_IMPACTO

La entidad `EVIDENCIA_IMPACTO` se había considerado como una posible entidad débil en la propuesta de inventario ampliado. Sin embargo, **no aparece en el diagrama EER mostrado**. Por lo tanto, no se contabiliza como una entidad existente del modelo entregado y no debe agregarse durante la transformación sin una modificación previa y documentada del modelo.

---

## 4. Relaciones y cardinalidades mínimas y máximas

Las cardinalidades indican cuántas instancias de una entidad pueden participar en una relación. El diagrama original muestra principalmente cardinalidades máximas; las mínimas se establecen a continuación como una interpretación de diseño que debe validarse con los requisitos del proyecto.

| Relación | Entidades participantes | Cardinalidad min-max | Justificación |
|---|---|---|---|
| **Pertenece a** | CATEGORIA — PRODUCTO | CATEGORIA (0,N); PRODUCTO (1,1) | Una categoría puede existir sin productos o agrupar varios. Cada producto debe pertenecer a una categoría. |
| **Se fabrica en** | PAIS — PRODUCTO | PAIS (0,N); PRODUCTO (1,1) | Un país puede tener varios productos registrados. En el modelo actual, cada producto tiene un país asociado. |
| **Compuesto por** | PRODUCTO — MATERIAL, mediante PRODUCTO_MATERIAL | PRODUCTO (0,N); MATERIAL (0,N) | Un producto puede estar compuesto por varios materiales y un material puede utilizarse en diferentes productos. |
| **Tiene** | PRODUCTO — IMPACTO_AMBIENTAL | PRODUCTO (0,N); IMPACTO_AMBIENTAL (1,1) | Un producto puede tener varios registros de impacto a lo largo del tiempo. Cada registro corresponde a un producto. |
| **Se obtiene de** | FUENTE — IMPACTO_AMBIENTAL | FUENTE (0,N); IMPACTO_AMBIENTAL (1,1) | Una fuente puede respaldar varios registros de impacto. Cada registro debe estar asociado con una fuente. |

**Aclaración:** las cardinalidades mínimas son decisiones propuestas para documentar el diseño. Deben confirmarse con las reglas de negocio y las observaciones del equipo docente. El diagrama original no muestra expresamente todos los mínimos.

### Claves foráneas derivadas de las relaciones

- `PRODUCTO.id_categoria` → `CATEGORIA.id_categoria`.
- `PRODUCTO.id_pais` → `PAIS.id_pais`.
- `PRODUCTO_MATERIAL.id_producto` → `PRODUCTO.id_producto`.
- `PRODUCTO_MATERIAL.id_material` → `MATERIAL.id_material`.
- `IMPACTO_AMBIENTAL.id_producto` → `PRODUCTO.id_producto`.
- `IMPACTO_AMBIENTAL.id_fuente` → `FUENTE.id_fuente`.

---

## 5. Jerarquía de generalización y especialización (ISA)

La entidad general `PRODUCTO` se especializa en dos subtipos:

### 5.1. PRODUCTO_REUTILIZABLE

Atributos específicos:

- `numero_reutilizaciones`
- `requiere_mantenimiento`

Representa los productos que pueden utilizarse varias veces.

### 5.2. PRODUCTO_DESECHABLE

Atributos específicos:

- `tiempo_descomposicion_anios`
- `genera_residuos`

Representa los productos destinados a desecharse después de su uso o que generan residuos asociados a su eliminación.

### 5.3. Restricciones de la jerarquía

- **Disyunción:** se propone que los subtipos sean disjuntos. Un producto no puede pertenecer simultáneamente a `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE`.
- **Completitud:** se propone una especialización parcial. Un producto puede permanecer registrado únicamente como `PRODUCTO` si todavía no se ha clasificado en alguno de los subtipos.

Estas restricciones son decisiones de diseño que deben conservarse durante la transformación, salvo que las observaciones del docente o los requisitos del proyecto indiquen lo contrario.

---

## 6. Atributos multivaluados, compuestos y derivados

| Tipo de atributo | Atributo | Entidad | Tratamiento propuesto |
|---|---|---|---|
| Compuesto (propuesto) | `vida_util` | PRODUCTO | Si se expresa mediante cantidad y unidad, se divide en `vida_util_cantidad` y `vida_util_unidad`. |
| Multivaluado (propuesto) | `certificaciones_ambientales` | PRODUCTO | Si se confirma en el modelo aprobado, se crea una tabla adicional para registrar varias certificaciones por producto. |
| Derivado (por definir) | `nivel_impacto` | IMPACTO_AMBIENTAL | Solo se considera derivado si se calcula a partir de las métricas ambientales mediante una regla definida. De lo contrario, se almacena como atributo normal. |

**Importante:** en el diagrama entregado, `vida_util` aparece como un atributo simple, mientras que `certificaciones_ambientales` no aparece. Por ello, la composición de `vida_util` y la incorporación de certificaciones son propuestas de ampliación, no elementos confirmados del diagrama original.

Los demás atributos visibles, como `nombre`, `marca`, `precio_aproximado`, `consumo_agua`, `consumo_energia`, `emisiones_co2` y `residuos_generados`, se consideran simples en el modelo actual.

---

## 7. Relaciones ternarias o de orden superior

En el diagrama EER entregado no se identifican relaciones ternarias ni relaciones de orden superior.

Las relaciones representadas son binarias. La relación entre productos y materiales se resuelve mediante la entidad asociativa `PRODUCTO_MATERIAL`, y los registros de impacto ambiental se relacionan con el producto y la fuente correspondiente.

Por lo tanto, no se requiere transformar ninguna relación ternaria en una tabla independiente a partir del diagrama actual.

---

## 8. Elementos que requieren una tabla adicional

Antes de transformar el modelo EER al modelo relacional, se identifican los siguientes casos:

1. **PRODUCTO_MATERIAL:** requiere una tabla asociativa porque resuelve la relación N:M entre `PRODUCTO` y `MATERIAL`.
2. **PRODUCTO_REUTILIZABLE y PRODUCTO_DESECHABLE:** si se elige la estrategia de tablas separadas para los subtipos, se crea una tabla para cada uno, utilizando `id_producto` como clave primaria y clave foránea hacia `PRODUCTO`.
3. **Certificaciones ambientales:** se necesitaría una tabla adicional únicamente si se aprueba el atributo multivaluado `certificaciones_ambientales`.
4. **Atributo compuesto `vida_util`:** no requiere por sí mismo una tabla adicional; sus componentes se almacenan como columnas de `PRODUCTO`.
5. **Atributos derivados:** normalmente se calculan mediante una expresión o consulta y no requieren una tabla adicional, salvo que exista una razón específica para almacenarlos.

---

## 9. Decisiones para transformar la jerarquía ISA

Para transformar la jerarquía de `PRODUCTO` se propone mantener una tabla para la entidad general y una tabla para cada subtipo.

- La tabla `PRODUCTO` conservará los atributos generales y la clave primaria `id_producto`.
- La tabla `PRODUCTO_REUTILIZABLE` almacenará `numero_reutilizaciones` y `requiere_mantenimiento`.
- La tabla `PRODUCTO_DESECHABLE` almacenará `tiempo_descomposicion_anios` y `genera_residuos`.
- En ambas tablas de subtipos, `id_producto` será clave primaria y clave foránea hacia `PRODUCTO(id_producto)`.
- Se conservarán las restricciones de disyunción y completitud parcial propuestas para la jerarquía.

Esta estrategia evita repetir los atributos generales de producto en las tablas de los subtipos y permite conservar su relación con la entidad padre.

---

## 10. Lista de verificación previa a la transformación

- [x] Entidades fuertes identificadas.
- [x] Claves primarias documentadas.
- [x] Entidad asociativa `PRODUCTO_MATERIAL` identificada.
- [x] Relaciones y cardinalidades máximas documentadas.
- [x] Cardinalidades mínimas propuestas y justificadas.
- [x] Jerarquía ISA y atributos de los subtipos identificados.
- [x] Restricciones de disyunción y completitud propuestas.
- [x] Atributos especiales revisados y diferencias respecto al diagrama señaladas.
- [x] Relaciones ternarias o de orden superior revisadas.
- [x] Tablas adicionales y claves foráneas previstas.

## 11. Conclusión

El inventario permite identificar los elementos principales del modelo EER de EcoData antes de transformarlo al modelo relacional. Se documentan las entidades fuertes, la asociación entre productos y materiales, las relaciones, las claves foráneas y la jerarquía de especialización de productos.

También se distinguen los elementos que aparecen en el diagrama original de las propuestas de ampliación, como las certificaciones ambientales y la descomposición del atributo `vida_util`. Esta distinción ayuda a evitar agregar elementos que no fueron aprobados y facilita verificar que la transformación conserve la estructura y las reglas del modelo entregado.
