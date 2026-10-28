# Práctica 3: Transformación del modelo EER al modelo relacional

## Datos de los estudiantes

| Nombre completo | Número de boleta |
|---|---|
| Marquez Chávez Kassumy Nallely | 2026630376 |
| Gutiérrez Cruz Alison | 2026670031 |
| Suárez Mendoza Lis Rosaura | 2024440302 |
| Rivera Munguia Ameyalli | 2025630902 |

### Información académica

| Dato | Detalle |
|---|---|
| Grupo | 3BV1 |
| Carrera | Ingeniería en Inteligencia Artificial |
| Materia | Bases de Datos |
| Institución | Instituto Politécnico Nacional |

---

## Índice

### Documentos

- [Investigación de bases de datos](./docs/investigación-base-de-datos.pdf)
- [Estado del arte](./docs/estado-del-arte.pdf)
- [Caso de estudio](./docs/caso-de-estudio.pdf)

### Modelo

- [Diagrama entidad-relación](./modelo/diagrama-er.png)
- [Modelo EER del proyecto propio](./proyecto-propio/inventario-eer.pdf)
- **Inventario del modelo EER:** incluido en este README.

### Entorno

- [Archivo Compose](./entorno/compose.yaml)

### Evidencias

- [Git](./evidencias/git/evidencia-Git.pdf)
- [Docker](./evidencias/docker/evidencia-docker.pdf)
- [Creación de la base de datos EcoData](./evidencias/ejercicio1-ecodata.png)
- [Verificación de obras públicas en PostgreSQL](./evidencias/verificacion-obras-publicas.png)

---

## Introducción

En esta práctica se continúa con el trabajo realizado en las prácticas anteriores de Bases de Datos. Se retoma el modelo Entidad-Relación Extendido (EER) del proyecto propio para identificar y registrar sus elementos antes de transformarlo en un modelo relacional.

Este inventario permite comprobar que las entidades, los atributos, las relaciones, las cardinalidades y las jerarquías de especialización se conserven durante la transformación. También sirve para identificar qué elementos necesitan tablas adicionales y cuáles se representan mediante claves primarias y foráneas.

## Proyecto propio: Impacto ambiental de productos cotidianos

El proyecto consiste en diseñar una base de datos que permita almacenar, organizar y consultar información sobre el impacto ambiental de distintos productos de uso cotidiano.

La propuesta considera datos como el consumo de agua y energía, las emisiones de CO₂, la generación de residuos, los materiales utilizados en la fabricación, la posibilidad de reciclaje y las fuentes de información ambiental.

### Objetivo general

Diseñar una base de datos que permita registrar y comparar el impacto ambiental de productos cotidianos mediante un modelo EER que pueda transformarse en un modelo relacional sin perder la información ni las restricciones definidas.

---

# Ejercicio 2. Inventario del modelo EER del proyecto propio

## 1. Entidades fuertes, atributos y claves primarias

Las entidades fuertes identificadas en el modelo EER son las siguientes:

| Entidad | Clave primaria | Atributos |
|---|---|---|
| **CATEGORÍA** | `id_categoria` | `id_categoria`, `nombre`, `descripcion` |
| **PRODUCTO** | `id_producto` | `id_producto`, `nombre`, `marca`, `precio_aproximado`, `vida_util`, `id_categoria`, `id_pais` |
| **PAÍS** | `id_pais` | `id_pais`, `nombre` |
| **MATERIAL** | `id_material` | `id_material`, `nombre`, `descripcion`, `tipo`, `reciclable` |
| **IMPACTO_AMBIENTAL** | `id_impacto` | `id_impacto`, `consumo_agua`, `consumo_energia`, `emisiones_co2`, `residuos_generados`, `nivel_impacto`, `fecha_dato`, `id_fuente` |
| **FUENTE** | `id_fuente` | `id_fuente`, `nombre`, `tipo`, `url`, `fecha_consulta` |

Las claves primarias identifican de manera única cada registro de su entidad. Los atributos `id_categoria`, `id_pais` e `id_fuente` que aparecen en otras entidades se utilizarán como claves foráneas cuando se realice la transformación al modelo relacional.

## 2. Entidades débiles y relaciones de identificación

En el modelo se identifica la entidad asociativa `PRODUCTO_MATERIAL`, que representa la relación entre productos y materiales. Su clave se compone de las claves de las entidades relacionadas.

| Entidad | Entidades de las que depende | Clave primaria propuesta | Función |
|---|---|---|---|
| **PRODUCTO_MATERIAL** | PRODUCTO y MATERIAL | (`id_producto`, `id_material`) | Registrar qué materiales forman parte de cada producto. |

La entidad `PRODUCTO_MATERIAL` utiliza una clave primaria compuesta por `id_producto` y `id_material`. Ambos atributos también son claves foráneas que hacen referencia a `PRODUCTO` y `MATERIAL`, respectivamente.

**Observación:** en el diagrama original, `PRODUCTO_MATERIAL` aparece como una entidad asociativa. Para considerarla formalmente una entidad débil, debe representarse con la notación correspondiente y documentarse su relación de identificación. No se identifica otra entidad débil de manera explícita en el diagrama proporcionado.

## 3. Relaciones y cardinalidades mínimas y máximas

Las cardinalidades se expresan como `(mínimo, máximo)`. El mínimo indica si la participación es opcional (`0`) u obligatoria (`1`), mientras que el máximo indica cuántas instancias pueden relacionarse.

| Relación | Entidades participantes | Cardinalidad mínima y máxima | Justificación |
|---|---|---|---|
| Pertenece a | CATEGORÍA — PRODUCTO | CATEGORÍA `(0,N)`; PRODUCTO `(1,1)` | Una categoría puede no tener productos o tener varios; cada producto pertenece a una categoría. |
| Se fabrica en | PAÍS — PRODUCTO | PAÍS `(0,N)`; PRODUCTO `(1,1)` | Un país puede estar relacionado con varios productos; cada producto tiene un país de fabricación registrado. |
| Compuesto por | PRODUCTO — MATERIAL | PRODUCTO `(1,N)`; MATERIAL `(0,N)` | Un producto se compone de uno o varios materiales; un material puede utilizarse en distintos productos o todavía no estar asociado a uno. |
| Tiene | PRODUCTO — IMPACTO_AMBIENTAL | PRODUCTO `(0,N)`; IMPACTO_AMBIENTAL `(1,1)` | Un producto puede tener varios registros de impacto a lo largo del tiempo; cada registro corresponde a un producto. |
| Se obtiene de | FUENTE — IMPACTO_AMBIENTAL | FUENTE `(0,N)`; IMPACTO_AMBIENTAL `(1,1)` | Una fuente puede respaldar varios registros; cada registro de impacto se asocia con una fuente. |

**Nota:** las cardinalidades mínimas se proponen de acuerdo con las reglas de negocio planteadas para el proyecto. Deben mantenerse consistentes con el diagrama EER definitivo y con las observaciones del docente.

## 4. Jerarquía de generalización y especialización

El modelo contiene una jerarquía ISA en la que `PRODUCTO` es la superclase y `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE` son las subclases.

### Superclase: PRODUCTO

Atributos generales:

- `id_producto` (clave primaria)
- `nombre`
- `marca`
- `precio_aproximado`
- `vida_util`
- `id_categoria`
- `id_pais`

### Subclase: PRODUCTO_REUTILIZABLE

Atributos específicos:

- `id_producto` (clave primaria y foránea que referencia a PRODUCTO)
- `numero_reutilizaciones`
- `requiere_mantenimiento`

### Subclase: PRODUCTO_DESECHABLE

Atributos específicos:

- `id_producto` (clave primaria y foránea que referencia a PRODUCTO)
- `tiempo_descomposicion_anios`
- `genera_residuos`

### Restricciones de la jerarquía

- **Disyunción:** las subclases se consideran disjuntas; un producto no puede pertenecer simultáneamente a ambas subclases.
- **Completitud:** la especialización se considera parcial; un producto puede existir sin pertenecer a ninguna de las dos subclases, si no se ha clasificado todavía como reutilizable o desechable.

### Decisión para la transformación

Se propone utilizar una tabla para la superclase `PRODUCTO` y una tabla para cada subclase. En las tablas de las subclases, `id_producto` será simultáneamente clave primaria y clave foránea de `PRODUCTO`.

Esta alternativa conserva los atributos comunes en una sola tabla y permite almacenar por separado los atributos específicos de cada tipo de producto.

## 5. Atributos multivaluados, compuestos y derivados

| Tipo de atributo | Atributo identificado o propuesto | Tratamiento en el modelo relacional |
|---|---|---|
| Compuesto | `vida_util` | Si se compone de cantidad y unidad, se separará en `vida_util_cantidad` y `vida_util_unidad`. |
| Multivaluado | `certificaciones_ambientales` (propuesto) | Se recomienda crear una tabla adicional `CERTIFICACION_PRODUCTO` con `id_producto` y `certificacion`. |
| Derivado | `nivel_impacto` (si se calcula a partir de las métricas ambientales) | Puede calcularse mediante una regla definida o almacenarse si se necesita conservar el resultado de la evaluación. |

**Importante:** el atributo multivaluado `certificaciones_ambientales` y el tratamiento derivado de `nivel_impacto` son propuestas para completar la documentación; no aparecen representados explícitamente como tales en el diagrama mostrado. Si no forman parte del modelo aprobado por el equipo, deben registrarse como propuestas y no como elementos ya implementados.

En el diagrama, `vida_util` aparece como un solo atributo. Su separación en cantidad y unidad se realizará únicamente si esa composición forma parte del modelo EER definitivo.

## 6. Relaciones ternarias o de orden superior

En el diagrama EER proporcionado no se identifica ninguna relación ternaria ni una relación de orden superior.

Las relaciones principales son binarias. La asociación entre `PRODUCTO` y `MATERIAL` se representa mediante `PRODUCTO_MATERIAL` para resolver la relación de muchos a muchos.

## 7. Elementos que deben revisarse antes de la transformación

### ¿Qué elementos van a requerir una tabla adicional?

- `PRODUCTO_MATERIAL`, para representar la relación de muchos a muchos entre PRODUCTO y MATERIAL.
- `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE`, si se conserva la estrategia de una tabla para la superclase y una para cada subclase.
- `CERTIFICACION_PRODUCTO`, únicamente si se incorpora el atributo multivaluado `certificaciones_ambientales` al modelo definitivo.

### ¿Qué atributos se convertirán en claves foráneas?

- `PRODUCTO.id_categoria` → `CATEGORIA.id_categoria`.
- `PRODUCTO.id_pais` → `PAIS.id_pais`.
- `PRODUCTO_MATERIAL.id_producto` → `PRODUCTO.id_producto`.
- `PRODUCTO_MATERIAL.id_material` → `MATERIAL.id_material`.
- `IMPACTO_AMBIENTAL.id_producto` → `PRODUCTO.id_producto`.
- `IMPACTO_AMBIENTAL.id_fuente` → `FUENTE.id_fuente`.
- `PRODUCTO_REUTILIZABLE.id_producto` → `PRODUCTO.id_producto`.
- `PRODUCTO_DESECHABLE.id_producto` → `PRODUCTO.id_producto`.
- `CERTIFICACION_PRODUCTO.id_producto` → `PRODUCTO.id_producto`, si se incorpora esa tabla.

### ¿Qué decisión tendrá que tomarse en cada jerarquía?

Para la jerarquía `PRODUCTO` se debe decidir cómo representar la superclase y sus subclases. La opción seleccionada consiste en mantener una tabla `PRODUCTO` y crear tablas independientes para `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE`.

También se deben conservar las restricciones de disyunción y completitud: las subclases son disjuntas y la especialización es parcial. Estas restricciones deben documentarse porque no todas se garantizan automáticamente mediante las claves primarias y foráneas.

## 8. Cambios realizados al modelo EER

Antes de transformar el modelo EER al modelo relacional, el equipo debe revisar las observaciones recibidas en la Práctica 2.

Por el momento, este inventario documenta la estructura identificada en el diagrama proporcionado y propone decisiones de transformación. No se registra ninguna corrección como definitiva sin verificar que haya sido aprobada por el equipo o solicitada por el docente.

Si se modifica el modelo, se actualizará esta sección indicando:

- **Elemento modificado:** nombre de la entidad, relación o atributo.
- **Cambio realizado:** descripción de la modificación.
- **Justificación:** observación del docente o regla de negocio que motivó el cambio.

## Conclusión

El inventario permite identificar las entidades, sus atributos y claves primarias, las relaciones y sus cardinalidades, la entidad asociativa y la jerarquía de especialización del proyecto EcoData. También anticipa los elementos que requieren tablas adicionales y las claves foráneas necesarias para mantener la integridad referencial.

Este registro servirá como lista de verificación durante la transformación al modelo relacional, para comprobar que se conserven los elementos y las restricciones del modelo EER original.

---

## Estado del proyecto

La Práctica 3 se está trabajando en la rama `practica-3` del repositorio del equipo. Los cambios se documentarán y versionarán mediante Git y GitHub.

## Herramientas utilizadas

- PostgreSQL como sistema gestor de bases de datos.
- Docker para ejecutar el entorno de PostgreSQL.
- Visual Studio Code como editor.
- Git y GitHub para el control de versiones y la colaboración.
