## ðŸŒ± Proyecto propio: EcoData

## PresentaciÃ³n del proyecto

En la siguiente presentaciÃ³n se expone el desarrollo del proyecto asignado, el modelo entidad-relaciÃ³n y las propuestas de mejora planteadas.

[**Ver presentaciÃ³n en Canva**](https://canva.link/d2wasuvhqncyrit)

**Landing Page:**

[ðŸŒ Abrir proyecto EcoData](https://lisie02.github.io/Practica-1-Modelo-entidad-relaci-n-/index.html)

---

## Proyecto asignado

**Fork del proyecto:**

[ðŸ”— PublicMunicipalWorks_DWH](https://github.com/lisie02/PublicMunicipalWorks_DWH)

**VersiÃ³n publicada:**

[ðŸŒ Abrir versiÃ³n publicada](https://lisie02.github.io/PublicMunicipalWorks_DWH/)

---

## PresentaciÃ³n

[ðŸ“„ Ver presentaciÃ³n de la prÃ¡ctica](./presentacion%20primera%20parte%20proyecto.pdf)

---

## Fichas de los artÃ­culos cientÃ­ficos

[ðŸ“„ Ver fichas de los tres artÃ­culos](./Fichas_Articulos.md)

---

## ðŸ‘¥ Integrantes y contribuciones

| Integrante | Actividades realizadas |
|---|---|
| Marquez ChÃ¡vez Kassumy Nallely | ArtÃ­culo |
| GutiÃ©rrez Cruz Alison | Proyecto asinado |
| SuÃ¡rez Mendoza Lis Rosaura | Proyecto propio: EcoData |
| Rivera MunguÃ­a Ameyalli | Modelo Entidad Relacion |

---  

# PrÃ¡ctica 1: Modelo Entidad-RelaciÃ³n
# PrÃ¡ctica 3: TransformaciÃ³n del modelo EER al modelo relacional

## Datos de los estudiantes

| Nombre completo | NÃºmero de boleta |
|---|---|
| Marquez ChÃ¡vez Kassumy Nallely | 2026630376 |
| GutiÃ©rrez Cruz Alison | 2026670031 |
| SuÃ¡rez Mendoza Lis Rosaura | 2024440302 |
| Rivera Munguia Ameyali | 2025630902 |

### InformaciÃ³n acadÃ©mica

| Dato | Detalle |
|---|---|
| Grupo | 3BV1 |
| Carrera | IngenierÃ­a en Inteligencia Artificial |
| Materia | Bases de Datos |
| InstituciÃ³n | Instituto PolitÃ©cnico Nacional |

---

## Ãndice

### Documentos

- [InvestigaciÃ³n de bases de datos](./docs/investigaciÃ³n-base-de-datos.pdf)
- [Estado del arte](./docs/estado-del-arte.pdf)
- [Caso de estudio](./docs/caso-de-estudio.pdf)

### Modelo

- [Diagrama entidad-relaciÃ³n](./modelo/diagrama-er.png)
- [Modelo EER del proyecto propio](./proyecto-propio/inventario-eer.pdf)
- **Inventario del modelo EER:** incluido en este README.

### Entorno

- [Archivo Compose](./entorno/compose.yml)

### Evidencias

- [Git](./evidencias/git/evidencia-Git.pdf)
- [Docker](./evidencias/docker/evidencia-docker.pdf)
- [CreaciÃ³n de la base de datos EcoData](./evidencias/ejercicio1-ecodata.png)
- [VerificaciÃ³n de obras pÃºblicas en PostgreSQL](./evidencias/verificacion-obras-publicas.png)

### Proyecto propio
- [Diccionario de datos de EcoData (PDF)](./proyecto-propio/diccionario-de-datos.pdf)
- [Diccionario de datos editable](./proyecto-propio/diccionario-de-datos.md)

---

## IntroducciÃ³n

En esta prÃ¡ctica se continÃºa con el trabajo realizado en las prÃ¡cticas anteriores de Bases de Datos. Se retoma el modelo Entidad-RelaciÃ³n Extendido (EER) del proyecto propio para identificar y registrar sus elementos antes de transformarlo en un modelo relacional.

Este inventario permite comprobar que las entidades, los atributos, las relaciones, las cardinalidades y las jerarquÃ­as de especializaciÃ³n se conserven durante la transformaciÃ³n. TambiÃ©n sirve para identificar quÃ© elementos necesitan tablas adicionales y cuÃ¡les se representan mediante claves primarias y forÃ¡neas.

## Proyecto propio: Impacto ambiental de productos cotidianos

El proyecto consiste en diseÃ±ar una base de datos que permita almacenar, organizar y consultar informaciÃ³n sobre el impacto ambiental de distintos productos de uso cotidiano.

La propuesta considera datos como el consumo de agua y energÃ­a, las emisiones de COâ‚‚, la generaciÃ³n de residuos, los materiales utilizados en la fabricaciÃ³n, la posibilidad de reciclaje y las fuentes de informaciÃ³n ambiental.

### Objetivo general

DiseÃ±ar una base de datos que permita registrar y comparar el impacto ambiental de productos cotidianos mediante un modelo EER que pueda transformarse en un modelo relacional sin perder la informaciÃ³n ni las restricciones definidas.

---

# Ejercicio 2. Inventario del modelo EER del proyecto propio

### Modelo relacional

- [Diagrama relacional con notaciÃ³n de pata de cuervo](./modelo/diagrama-relacional.png)
- [Datos de productos e impactos ambientales](./modelo/productos_mexico.sql)
- [RestricciÃ³n de disyunciÃ³n de la jerarquÃ­a ISA](./modelo/restriccion_isa.sql)
- [Inventario del modelo EER](./proyecto-propio/inventario-eer.md)

## 1. Entidades fuertes, atributos y claves primarias

Las entidades fuertes identificadas en el modelo EER son las siguientes:

| Entidad | Clave primaria | Atributos |
|---|---|---|
| **CATEGORÃA** | `id_categoria` | `id_categoria`, `nombre`, `descripcion` |
| **PRODUCTO** | `id_producto` | `id_producto`, `nombre`, `marca`, `precio_aproximado`, `vida_util`, `id_categoria`, `id_pais` |
| **PAÃS** | `id_pais` | `id_pais`, `nombre` |
| **MATERIAL** | `id_material` | `id_material`, `nombre`, `descripcion`, `tipo`, `reciclable` |
| **IMPACTO_AMBIENTAL** | `id_impacto` | `id_impacto`, `consumo_agua`, `consumo_energia`, `emisiones_co2`, `residuos_generados`, `nivel_impacto`, `fecha_dato`, `id_fuente` |
| **FUENTE** | `id_fuente` | `id_fuente`, `nombre`, `tipo`, `url`, `fecha_consulta` |

Las claves primarias identifican de manera Ãºnica cada registro de su entidad. Los atributos `id_categoria`, `id_pais` e `id_fuente` que aparecen en otras entidades se utilizarÃ¡n como claves forÃ¡neas cuando se realice la transformaciÃ³n al modelo relacional.

## 2. Entidades dÃ©biles y relaciones de identificaciÃ³n

En el modelo se identifica la entidad asociativa `PRODUCTO_MATERIAL`, que representa la relaciÃ³n entre productos y materiales. Su clave se compone de las claves de las entidades relacionadas.

| Entidad | Entidades de las que depende | Clave primaria propuesta | FunciÃ³n |
|---|---|---|---|
| **PRODUCTO_MATERIAL** | PRODUCTO y MATERIAL | (`id_producto`, `id_material`) | Registrar quÃ© materiales forman parte de cada producto. |

La entidad `PRODUCTO_MATERIAL` utiliza una clave primaria compuesta por `id_producto` y `id_material`. Ambos atributos tambiÃ©n son claves forÃ¡neas que hacen referencia a `PRODUCTO` y `MATERIAL`, respectivamente.

**ObservaciÃ³n:** en el diagrama original, `PRODUCTO_MATERIAL` aparece como una entidad asociativa. Para considerarla formalmente una entidad dÃ©bil, debe representarse con la notaciÃ³n correspondiente y documentarse su relaciÃ³n de identificaciÃ³n. No se identifica otra entidad dÃ©bil de manera explÃ­cita en el diagrama proporcionado.

## 3. Relaciones y cardinalidades mÃ­nimas y mÃ¡ximas

Las cardinalidades se expresan como `(mÃ­nimo, mÃ¡ximo)`. El mÃ­nimo indica si la participaciÃ³n es opcional (`0`) u obligatoria (`1`), mientras que el mÃ¡ximo indica cuÃ¡ntas instancias pueden relacionarse.

| RelaciÃ³n | Entidades participantes | Cardinalidad mÃ­nima y mÃ¡xima | JustificaciÃ³n |
|---|---|---|---|
| Pertenece a | CATEGORÃA â€” PRODUCTO | CATEGORÃA `(0,N)`; PRODUCTO `(1,1)` | Una categorÃ­a puede no tener productos o tener varios; cada producto pertenece a una categorÃ­a. |
| Se fabrica en | PAÃS â€” PRODUCTO | PAÃS `(0,N)`; PRODUCTO `(0,1)` | Un paÃ­s puede estar relacionado con varios productos. El paÃ­s de fabricaciÃ³n de un producto puede quedar sin especificar cuando no se cuenta con informaciÃ³n confirmada. |
| Tiene | PRODUCTO â€” IMPACTO_AMBIENTAL | PRODUCTO `(0,N)`; IMPACTO_AMBIENTAL `(1,1)` | Un producto puede tener varios registros de impacto a lo largo del tiempo; cada registro corresponde a un producto. |
| Se obtiene de | FUENTE â€” IMPACTO_AMBIENTAL | FUENTE `(0,N)`; IMPACTO_AMBIENTAL `(1,1)` | Una fuente puede respaldar varios registros; cada registro de impacto se asocia con una fuente. |

**Nota:** las cardinalidades mÃ­nimas se proponen de acuerdo con las reglas de negocio planteadas para el proyecto. Deben mantenerse consistentes con el diagrama EER definitivo y con las observaciones del docente.

## 4. JerarquÃ­a de generalizaciÃ³n y especializaciÃ³n

El modelo contiene una jerarquÃ­a ISA en la que `PRODUCTO` es la superclase y `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE` son las subclases.

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

Atributos especÃ­ficos:

- `id_producto` (clave primaria y forÃ¡nea que referencia a PRODUCTO)
- `numero_reutilizaciones`
- `requiere_mantenimiento`

### Subclase: PRODUCTO_DESECHABLE

Atributos especÃ­ficos:

- `id_producto` (clave primaria y forÃ¡nea que referencia a PRODUCTO)
- `tiempo_descomposicion_anios`
- `genera_residuos`

### Restricciones de la jerarquÃ­a

- **DisyunciÃ³n:** las subclases se consideran disjuntas; un producto no puede pertenecer simultÃ¡neamente a ambas subclases.
- **Completitud:** la especializaciÃ³n se considera parcial; un producto puede existir sin pertenecer a ninguna de las dos subclases, si no se ha clasificado todavÃ­a como reutilizable o desechable.

### DecisiÃ³n para la transformaciÃ³n

Se propone utilizar una tabla para la superclase `PRODUCTO` y una tabla para cada subclase. En las tablas de las subclases, `id_producto` serÃ¡ simultÃ¡neamente clave primaria y clave forÃ¡nea de `PRODUCTO`.

Esta alternativa conserva los atributos comunes en una sola tabla y permite almacenar por separado los atributos especÃ­ficos de cada tipo de producto.

## 5. Atributos multivaluados, compuestos y derivados

| Tipo de atributo | Atributo identificado o propuesto | Tratamiento en el modelo relacional |
|---|---|---|
| Compuesto | `vida_util` | Si se compone de cantidad y unidad, se separarÃ¡ en `vida_util_cantidad` y `vida_util_unidad`. |
| Multivaluado | `certificaciones_ambientales` (propuesto) | Se recomienda crear una tabla adicional `CERTIFICACION_PRODUCTO` con `id_producto` y `certificacion`. |
| Derivado | `nivel_impacto` (si se calcula a partir de las mÃ©tricas ambientales) | Puede calcularse mediante una regla definida o almacenarse si se necesita conservar el resultado de la evaluaciÃ³n. |

**Importante:** el atributo multivaluado `certificaciones_ambientales` y el tratamiento derivado de `nivel_impacto` son propuestas para completar la documentaciÃ³n; no aparecen representados explÃ­citamente como tales en el diagrama mostrado. Si no forman parte del modelo aprobado por el equipo, deben registrarse como propuestas y no como elementos ya implementados.

En el diagrama, `vida_util` aparece como un solo atributo. Su separaciÃ³n en cantidad y unidad se realizarÃ¡ Ãºnicamente si esa composiciÃ³n forma parte del modelo EER definitivo.

## 6. Relaciones ternarias o de orden superior

En el diagrama EER proporcionado no se identifica ninguna relaciÃ³n ternaria ni una relaciÃ³n de orden superior.

Las relaciones principales son binarias. La asociaciÃ³n entre `PRODUCTO` y `MATERIAL` se representa mediante `PRODUCTO_MATERIAL` para resolver la relaciÃ³n de muchos a muchos.

## 7. Elementos que deben revisarse antes de la transformaciÃ³n

### Â¿QuÃ© elementos van a requerir una tabla adicional?

- `PRODUCTO_MATERIAL`, para representar la relaciÃ³n de muchos a muchos entre PRODUCTO y MATERIAL.
- `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE`, si se conserva la estrategia de una tabla para la superclase y una para cada subclase.
- `CERTIFICACION_PRODUCTO`, Ãºnicamente si se incorpora el atributo multivaluado `certificaciones_ambientales` al modelo definitivo.

### Â¿QuÃ© atributos se convertirÃ¡n en claves forÃ¡neas?

- `PRODUCTO.id_categoria` â†’ `CATEGORIA.id_categoria`.
- `PRODUCTO.id_pais` â†’ `PAIS.id_pais`.
- `PRODUCTO_MATERIAL.id_producto` â†’ `PRODUCTO.id_producto`.
- `PRODUCTO_MATERIAL.id_material` â†’ `MATERIAL.id_material`.
- `IMPACTO_AMBIENTAL.id_producto` â†’ `PRODUCTO.id_producto`.
- `IMPACTO_AMBIENTAL.id_fuente` â†’ `FUENTE.id_fuente`.
- `PRODUCTO_REUTILIZABLE.id_producto` â†’ `PRODUCTO.id_producto`.
- `PRODUCTO_DESECHABLE.id_producto` â†’ `PRODUCTO.id_producto`.
- `CERTIFICACION_PRODUCTO.id_producto` â†’ `PRODUCTO.id_producto`, si se incorpora esa tabla.

### Â¿QuÃ© decisiÃ³n tendrÃ¡ que tomarse en cada jerarquÃ­a?

Para la jerarquÃ­a `PRODUCTO` se debe decidir cÃ³mo representar la superclase y sus subclases. La opciÃ³n seleccionada consiste en mantener una tabla `PRODUCTO` y crear tablas independientes para `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE`.

TambiÃ©n se deben conservar las restricciones de disyunciÃ³n y completitud: las subclases son disjuntas y la especializaciÃ³n es parcial. Estas restricciones deben documentarse porque no todas se garantizan automÃ¡ticamente mediante las claves primarias y forÃ¡neas.

## 8. Cambios realizados al modelo EER

Antes de transformar el modelo EER al modelo relacional, el equipo debe revisar las observaciones recibidas en la PrÃ¡ctica 2.

Por el momento, este inventario documenta la estructura identificada en el diagrama proporcionado y propone decisiones de transformaciÃ³n. No se registra ninguna correcciÃ³n como definitiva sin verificar que haya sido aprobada por el equipo o solicitada por el docente.

Si se modifica el modelo, se actualizarÃ¡ esta secciÃ³n indicando:

- **Elemento modificado:** nombre de la entidad, relaciÃ³n o atributo.
- **Cambio realizado:** descripciÃ³n de la modificaciÃ³n.
- **JustificaciÃ³n:** observaciÃ³n del docente o regla de negocio que motivÃ³ el cambio.

Inventario y transformaciÃ³n del modelo EER

Proyecto propio: EcoData

EcoData permite organizar informaciÃ³n sobre productos cotidianos y su impacto ambiental, considerando materiales, consumo de agua y energÃ­a, emisiones de COâ‚‚, generaciÃ³n de residuos y fuentes de informaciÃ³n.

Entregables

Inventario del modelo EER

Diagrama EER original

Diagrama relacional con notaciÃ³n de pata de cuervo

CÃ³digo SQL de EcoData

VerificaciÃ³n de las pruebas de integridad

## ImplementaciÃ³n y pruebas

El esquema relacional de EcoData se implementÃ³ en PostgreSQL mediante Docker. La base de datos cuenta con nueve tablas: `categoria`, `pais`, `material`, `producto`, `producto_material`, `impacto_ambiental`, `fuente`, `producto_reutilizable` y `producto_desechable`.

Se verificaron las claves primarias y forÃ¡neas de las tablas. TambiÃ©n se comprobÃ³ que `producto_material` utiliza una clave primaria compuesta por `id_producto` e `id_material`, lo que permite identificar cada relaciÃ³n entre un producto y un material.

### RestricciÃ³n de la jerarquÃ­a ISA

La jerarquÃ­a ISA tiene como superclase a `PRODUCTO` y como subclases a `PRODUCTO_REUTILIZABLE` y `PRODUCTO_DESECHABLE`. La disyunciÃ³n se implementÃ³ mediante disparadores definidos en `modelo/restriccion_isa.sql`.

Durante las pruebas se intentÃ³ registrar un mismo producto en ambas subclases. PostgreSQL rechazÃ³ el segundo registro y mostrÃ³ el mensaje correspondiente. Posteriormente, se comprobÃ³ que no quedaron registros de prueba en ninguna de las dos tablas.

La especializaciÃ³n es parcial, por lo que un producto puede permanecer sin clasificaciÃ³n en las subclases hasta que se disponga de informaciÃ³n para determinar si es reutilizable o desechable.

### Datos ambientales de los envases

Se incorporaron tres productos comparativos para envases de refresco de 355 ml: una botella de PET, un envase de vidrio y una lata de aluminio. Cada producto se relacionÃ³ con su material principal y con un registro de impacto ambiental asociado a la fuente de la UANL utilizada en el proyecto.

Los registros almacenan el consumo de energÃ­a y las emisiones de COâ‚‚ equivalente del caso nacional analizado. Los valores utilizados son:

| Producto | EnergÃ­a (MJ) | Emisiones (kg COâ‚‚e) |
|---|---:|---:|
| Botella PET | 1.8 | 0.095 |
| Envase de vidrio | 7.6 | 0.813 |
| Lata de aluminio | 5.1 | 0.301 |

Los niveles de impacto registrados son relativos a los tres envases comparados en ese caso de estudio; no representan una clasificaciÃ³n universal. El consumo de agua y los residuos generados se mantienen sin dato cuando la fuente utilizada no proporciona valores para esos atributos.

El paÃ­s de fabricaciÃ³n de los tres productos se dejÃ³ sin especificar, ya que la fuente consultada no confirma el lugar de fabricaciÃ³n de cada envase.
### Fuente de datos ambientales

Los valores de consumo de energÃ­a y emisiones de COâ‚‚ equivalente utilizados en EcoData se obtuvieron de la Tabla III del Caso de estudio I (anÃ¡lisis nacional), publicado por Cabriales GÃ³mez y colaboradores en 2024. El estudio compara envases de PET, vidrio y aluminio de 355 ml utilizados para refrescos en MÃ©xico.

**Referencia en formato APA 7:**

Cabriales GÃ³mez, R. C., Arroyo Mayorga, Y. M., Cobos Zaleta, D., & Reyes Osorio, L. A. (2024). Sustentabilidad de materiales para el envasado de refrescos implementando un AnÃ¡lisis de Ciclo de Vida mediante SolidWorks Sustainability. *Ingenierias, 27*(96), 11â€“26. https://doi.org/10.29105/ingenierias27.96-947

**Alcance y limitaciones de los datos:** los resultados corresponden al escenario nacional descrito por los autores y no deben interpretarse como valores universales para todos los envases. La base de datos registra actualmente el consumo de energÃ­a y las emisiones de COâ‚‚ equivalente. Los valores de acidificaciÃ³n atmosfÃ©rica y eutrofizaciÃ³n del agua reportados por el artÃ­culo no se incorporaron porque el esquema actual no contiene atributos especÃ­ficos para esos indicadores. Tampoco se asignÃ³ un paÃ­s de fabricaciÃ³n a cada producto, ya que no se confirmÃ³ ese dato individualmente.

### Prueba de ejecuciÃ³n repetida

Se ejecutÃ³ nuevamente `modelo/productos_mexico.sql` para comprobar que los registros existentes no se duplicaran. El script terminÃ³ con `COMMIT` y las instrucciones correspondientes devolvieron `INSERT 0 0`.

La consulta de verificaciÃ³n confirmÃ³ la existencia de tres productos, tres relaciones producto-material y tres registros de impacto ambiental despuÃ©s de la segunda ejecuciÃ³n.

Estas pruebas permiten comprobar la integridad referencial, el funcionamiento de la restricciÃ³n ISA y la prevenciÃ³n de duplicados en los datos incorporados al proyecto.

## ConclusiÃ³n

El inventario permite identificar las entidades, sus atributos y claves primarias, las relaciones y sus cardinalidades, la entidad asociativa y la jerarquÃ­a de especializaciÃ³n del proyecto EcoData. TambiÃ©n anticipa los elementos que requieren tablas adicionales y las claves forÃ¡neas necesarias para mantener la integridad referencial.

Este registro servirÃ¡ como lista de verificaciÃ³n durante la transformaciÃ³n al modelo relacional, para comprobar que se conserven los elementos y las restricciones del modelo EER original.

---

## Proyecto asignado

El proyecto asignado es *A Dimensional Data Warehouse for Geospatial Monitoring of Municipal Public Works, with an Evolution Path Toward a Lakehouse Architecture*. Su objetivo es apoyar el monitoreo geoespacial de obras pÃºblicas municipales mediante un almacÃ©n dimensional, datos histÃ³ricos y consultas analÃ­ticas.

- [Repositorio original del proyecto asignado](https://github.com/gabrielhuav/PublicMunicipalWorks_DWH)
- [AnÃ¡lisis del esquema](./proyecto-asignado/analisis-del-esquema.pdf)
- [AnÃ¡lisis del esquema en formato editable](./proyecto-asignado/analisis-del-esquema.md)
- [ComparaciÃ³n entre los modelos EER y relacional](./proyecto-asignado/comparacion-eer-relacional.pdf)
- [ComparaciÃ³n en formato editable](./proyecto-asignado/comparacion-eer-relacional.md)

### Gestor de base de datos

Se utilizÃ³ PostgreSQL ejecutado mediante Docker. Para el proyecto propio se trabajÃ³ con la base `ecodata`; para el proyecto asignado, con la base `obras_publicas`, que contiene el esquema dimensional `warehouse` y el esquema operativo `public`.

## Cambio individual de esquema con IA â€” Ejercicio 8

La propuesta individual consiste en preparar el esquema para almacenar predicciones de riesgo de retraso de obras pÃºblicas, vinculando cada resultado con la obra y el periodo evaluados, la versiÃ³n del modelo y la fecha de generaciÃ³n.

- [Issue original: predicciÃ³n inteligente de retrasos en obras pÃºblicas](https://github.com/lisie02/Practica-1-Modelo-entidad-relaci-n-/issues/3)
- [Script del cambio de esquema](./cambios/cambio-lisie02.sql)
- [Consulta de demostraciÃ³n](./cambios/consulta-prediccion-lisie02.sql)
- [Nota explicativa en PDF](./cambios/cambio-lisie02.pdf)
- [Nota explicativa editable](./cambios/cambio-lisie02.md)
- [Evidencia de ejecuciÃ³n del cambio SQL](./evidencias/ejercicio8/01-ejecucion-cambio-sql.png)
- [Evidencia de la consulta de predicciÃ³n](./evidencias/ejercicio8/02-consulta-prediccion.png)
- [Evidencia de verificaciÃ³n de tablas y rollback](./evidencias/ejercicio8/03-verificacion-tablas-y-rollback.png)

La consulta realizada utiliza datos demostrativos y no representa la salida de un modelo de aprendizaje automÃ¡tico entrenado. El esquema quedÃ³ preparado para registrar predicciones, pero el entrenamiento y la validaciÃ³n de un modelo real son trabajos posteriores.

## DeclaraciÃ³n del uso de inteligencia artificial generativa

Se utilizÃ³ ChatGPT como herramienta de apoyo para revisar el enunciado de la prÃ¡ctica, proponer borradores de documentaciÃ³n, orientar la escritura de scripts SQL y explicar los resultados de las pruebas. Los scripts se ejecutaron en PostgreSQL y se verificaron sus resultados. La estudiante revisÃ³ los cambios y debe poder explicar las decisiones de diseÃ±o y las restricciones implementadas.


---

## Estado del proyecto

La PrÃ¡ctica 3 se estÃ¡ trabajando en la rama `practica-3` del repositorio del equipo. Los cambios se documentarÃ¡n y versionarÃ¡n mediante Git y GitHub.

## Herramientas utilizadas

- PostgreSQL como sistema gestor de bases de datos.
- Docker para ejecutar el entorno de PostgreSQL.
- Visual Studio Code como editor.
- Git y GitHub para el control de versiones y la colaboraciÃ³n.




---

# Practica 5. Edicion de valores e integridad referencial

En esta practica se trabajaron las operaciones DML, las restricciones de integridad referencial y las transacciones en PostgreSQL.

## Documentacion del proyecto propio: EcoData

- [Claves foraneas y relaciones del modelo](./practica5/referencias.md)
- [Pruebas de integridad referencial](./practica5/pruebas-referenciales.md)
- [Edicion de valores y transacciones](./practica5/edicion-de-valores.md)

## Proyecto asignado: Obras publicas municipales

- [Integridad referencial del almacen dimensional](./practica5/integridad-almacen.md)

## Scripts SQL

| Archivo | Descripcion |
|---|---|
| [001-acciones-referenciales.sql](./practica5/sql/001-acciones-referenciales.sql) | Configuracion de acciones referenciales en EcoData. |
| [002-pruebas-referenciales.sql](./practica5/sql/002-pruebas-referenciales.sql) | Pruebas de RESTRICT, SET NULL, CASCADE y claves foraneas. |
| [003-verificacion-integridad.sql](./practica5/sql/003-verificacion-integridad.sql) | Verificacion de integridad en las dos bases. |
| [004-borrado-logico.sql](./practica5/sql/004-borrado-logico.sql) | Incorporacion de la columna activo en la copia de pruebas. |
| [005-edicion-transacciones.sql](./practica5/sql/005-edicion-transacciones.sql) | Operaciones INSERT, UPDATE, DELETE y SAVEPOINT. |
| [006-transaccion-fallida.sql](./practica5/sql/006-transaccion-fallida.sql) | Prueba de reversibilidad ante una restriccion CHECK. |
| [007-verificacion-almacen.sql](./practica5/sql/007-verificacion-almacen.sql) | Comprobaciones del almacen de obras publicas. |
| [008-cambio-lisie-mendoza.sql](./practica5/sql/008-cambio-lisie-mendoza.sql) | Cambio individual de RESTRICT a CASCADE. |
| [009-prueba-cascade-lisie-mendoza.sql](./practica5/sql/009-prueba-cascade-lisie-mendoza.sql) | Comparacion del borrado con CASCADE. |

## Trabajo individual: Lisie Mendoza

- [Documento individual firmado](./practica5/integrantes/lisie-mendoza.md)
- [Evidencias del ejercicio 2.6](./practica5/evidencias/ejercicio-2.6/)

### Evidencias

1. [Comportamiento original RESTRICT](./practica5/evidencias/ejercicio-2.6/01-restrict-original.png)
2. [Migracion de RESTRICT a CASCADE](./practica5/evidencias/ejercicio-2.6/02-migracion-cascade.png)
3. [Comparacion antes y despues del borrado](./practica5/evidencias/ejercicio-2.6/03-borrado-cascade-antes-despues.png)
4. [Comprobacion del ROLLBACK](./practica5/evidencias/ejercicio-2.6/04-rollback-conteos-restaurados.png)

**Nota:** El cambio individual se ejecuto en la copia `ecodata_individual_lisie`. La base original `ecodata` no fue modificada.


---

---

# Aplicacion web EcoData

EcoData cuenta con una aplicacion web conectada a PostgreSQL que permite consultar productos, comparar indicadores ambientales y gestionar cuentas de usuario.

## Documentacion tecnica

- [Documentacion tecnica del sistema](./docs/ECODATA-DOCUMENTACION-TECNICA.md)
- [Indice de evidencias de funcionamiento](./docs/INDICE-EVIDENCIAS.md)

## Evidencias de funcionamiento

- [Pagina principal](./evidencias/ecodata-web/01-pagina-principal.png)
- [Registro de usuarios](./evidencias/ecodata-web/02-registro-usuarios.png)
- [Inicio de sesion](./evidencias/ecodata-web/03-inicio-sesion.png)
- [Consulta de productos](./evidencias/ecodata-web/04-consulta-productos.png)
- [Filtros PET](./evidencias/ecodata-web/05-filtros-pet.png)
- [Comparacion de productos](./evidencias/ecodata-web/06-comparacion-productos.png)
- [Conexion con PostgreSQL](./evidencias/ecodata-web/07-conexion-base-datos.png)
