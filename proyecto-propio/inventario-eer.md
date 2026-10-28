# Ejercicio 2. Inventario del modelo EER del proyecto propio

## Proyecto EcoData: Impacto ambiental de productos cotidianos
Identificar las entidades fuertes
De acuerdo con tu diagrama EER de EcoData, tenemos seis entidades fuertes.
Entidad	Clave primaria	Atributos
CATEGORIA	id_categoria	nombre, descripcion
PRODUCTO	id_producto	nombre, marca, precio_aproximado, vida_util
PAIS	id_pais	nombre
MATERIAL	id_material	nombre, descripcion, tipo, reciclable
IMPACTO_AMBIENTAL	id_impacto	consumo_agua, consumo_energia, emisiones_co2, residuos_generados, nivel_impacto, fecha_dato
FUENTE	id_fuente	nombre, tipo, url, fecha_consulta

Identificar las entidades débiles
En tu diagrama aparece PRODUCTO_MATERIAL, que permite relacionar productos con los materiales que los componen.

Su clave primaria es compuesta:
\[
PK=(id\_producto,\ id\_material)
\]

- id_producto referencia a PRODUCTO.
- id_material referencia a MATERIAL.

Registrar las relaciones y cardinalidades
Las relaciones que se observan en tu diagrama son:
Relación	Cardinalidad máxima	Interpretación
CATEGORIA — PRODUCTO	1:N	Una categoría puede agrupar varios productos.
PAIS — PRODUCTO	1:N	Un país puede estar asociado a varios productos.
PRODUCTO — MATERIAL	N:M	Un producto puede utilizar varios materiales y un material puede usarse en varios productos.
PRODUCTO — IMPACTO_AMBIENTAL	1:N	Un producto puede tener varios registros de impacto ambiental.
FUENTE — IMPACTO_AMBIENTAL	1:N	Una fuente puede respaldar varios registros de impacto.

Las cardinalidades mínimas deben confirmarse con las reglas de negocio del equipo y la versión definitiva del diagrama. No basta con la notación 1:N para saber si la participación es opcional u obligatoria.

Registrar la jerarquía ISA
Tu modelo contiene una jerarquía de especialización:
- Superclase: PRODUCTO.
- Subclase 1: PRODUCTO_REUTILIZABLE.
  - numero_reutilizaciones
  - requiere_mantenimiento
- Subclase 2: PRODUCTO_DESECHABLE.
  - tiempo_descomposicion_anios
  - genera_residuos
Las restricciones planteadas para esta jerarquía son:
- Disyunta: un producto no puede pertenecer simultáneamente a ambas subclases.
- Parcial: puede haber productos que todavía no estén clasificados en ninguna subclase.
La decisión de transformación propuesta es crear una tabla PRODUCTO y tablas independientes para las dos subclases. En estas últimas, id_producto será clave primaria y clave foránea hacia PRODUCTO.

Revisar los atributos especiales
Tipo	Atributo	Tratamiento
Compuesto	vida_util	Si contiene cantidad y unidad, se divide en vida_util_cantidad y vida_util_unidad.
Multivaluado	certificaciones_ambientales	Solo si forma parte del modelo aprobado, requiere una tabla adicional para registrar varias certificaciones por producto.
Derivado	nivel_impacto	Si se calcula a partir de las métricas ambientales, debe definirse la regla de cálculo.

Las claves foráneas que aparecen en el diagrama también se documentarán al revisar las relaciones. Por ejemplo, id_categoria y id_pais se encuentran en PRODUCTO.
Contestar las preguntas previas a la transformación
¿Qué elementos requieren una tabla adicional?
- PRODUCTO_MATERIAL, para resolver la relación N:M.
- PRODUCTO_REUTILIZABLE y PRODUCTO_DESECHABLE, si se conserva la estrategia de tablas separadas para las subclases.
- Una tabla de certificaciones, únicamente si se confirma el atributo multivaluado.
¿Qué atributos se convertirán en claves foráneas?
- PRODUCTO.id_categoria → CATEGORIA.id_categoria
- PRODUCTO.id_pais → PAIS.id_pais
- PRODUCTO_MATERIAL.id_producto → PRODUCTO.id_producto
- PRODUCTO_MATERIAL.id_material → MATERIAL.id_material
- IMPACTO_AMBIENTAL.id_producto → PRODUCTO.id_producto
- IMPACTO_AMBIENTAL.id_fuente → FUENTE.id_fuente
- PRODUCTO_REUTILIZABLE.id_producto → PRODUCTO.id_producto
- PRODUCTO_DESECHABLE.id_producto → PRODUCTO.id_producto
¿Qué decisión se toma en la jerarquía?

Mantener una tabla para PRODUCTO y una tabla para cada subclase, con id_producto como clave primaria y foránea en las subclases. Se conservarán las restricciones disjunta y parcial.