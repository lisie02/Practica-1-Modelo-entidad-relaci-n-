# Ejercicio 7.3. Comparación entre el modelo EER y el relacional

**Proyecto asignado:** Obras Públicas Municipales / `PublicMunicipalWorks_DWH`  
**Materia:** Bases de Datos — Práctica 3

## 1. Propósito y alcance

La comparación utiliza dos niveles del proyecto asignado: (1) el diagrama EER de Obras Públicas Municipales revisado en la Práctica 2 y (2) el DDL del almacén dimensional del repositorio `PublicMunicipalWorks_DWH`. Estos modelos cumplen propósitos distintos: el EER describe las entidades y reglas del dominio operacional, mientras que el DDL organiza información para análisis de eventos, historial y snapshots mensuales.

Por esa diferencia, no se espera una correspondencia uno-a-uno entre cada entidad del EER y una tabla del almacén. La comparación identifica qué se conserva en el esquema dimensional, qué se transforma y qué no se encuentra representado explícitamente en el DDL revisado. La ausencia de una tabla en este DDL no prueba que la información no exista en otra parte del sistema.

## 2. Comparación por elemento del modelo

| Elemento del EER | Representación en el esquema dimensional | Qué se gana | Qué se pierde o requiere cuidado |
|---|---|---|---|
| **Entidades fuertes** (`OBRA`, `REGIÓN`, `EMPRESA CONTRATISTA`, `PRESUPUESTO`, `PERSONAL TÉCNICO`, `TIPO DE EVENTO`) | Se reflejan principalmente en `dim_obra`, `dim_region`, `dim_constructora`, `dim_presupuesto`, `dim_personal` y `dim_tipo_evento`. Los hechos tienen referencias a estas dimensiones. | Claves sustitutas uniformes, atributos preparados para filtros y agrupaciones y posibilidad de análisis histórico. | No es una copia exacta del modelo operacional. Varias dimensiones contienen atributos combinados y las referencias entre ciertas dimensiones no están declaradas como FKs. |
| **Entidad débil `EVIDENCIA`** | En las tablas de hechos aparecen `documento_referencia`, `url_evidencia` e `imagenes_evidencia`; el DDL revisado no declara una tabla de dimensión o detalle llamada `evidencia`. | Para indicadores agregados, la cantidad de imágenes y las referencias a documentos permiten asociar evidencia al evento o al periodo sin cargar todos los metadatos en el hecho. | No se observa en este DDL una fila relacional por cada evidencia con su número parcial, tipo, URL y descripción. El detalle puede estar fuera del almacén (por ejemplo, en la capa de objetos/operacional), pero debe comprobarse en el resto del sistema antes de afirmar que está perdido. |
| **Relación muchos a muchos `PROPUESTA CIUDADANA`–`OBRA`** | `fact_eventos_auditoria` puede incluir a la vez `propuesta_key` y `obra_key`; no hay una tabla puente dedicada visible en el DDL revisado. | Los eventos relacionados con propuestas y obras pueden analizarse junto a tiempo, tipo de evento y otras dimensiones. | La coexistencia de dos claves en una tabla de hechos no demuestra por sí sola que se preserve toda la relación N:M independiente de los eventos. Si se requiere consultar cada asociación propuesta-obra como relación de dominio, hace falta verificar el proceso ETL y el grano de los hechos o modelar una tabla puente. |
| **Relaciones 1:N** (región-obra, obra-evento, tipo-evento-evento, obra-snapshot mensual) | Se representan con referencias de claves y con la selección del grano de los hechos. `fact_eventos_auditoria` tiene FKs a tiempo y tipo de evento obligatorias; otras referencias dimensionales son opcionales. `fact_obra_mensual` tiene FKs obligatorias a tiempo y obra. | Cada hecho se puede asociar a dimensiones y analizar por fecha, obra, región, personal, constructora y tipo de evento. | Las referencias opcionales admiten filas de hechos sin una dimensión concreta. Además, varias claves dentro de dimensiones no tienen FK explícita, por lo que parte de la integridad depende del ETL y de pruebas de calidad. |
| **Jerarquías/roles del personal** | `dim_personal` concentra el atributo `rol` y las banderas `es_supervisor`, `es_proyectista`, `es_director` y `es_secretario` en una misma tabla. | Filtrar por rol es sencillo y no requiere unirse con una tabla por subtipo. | El DDL no implementa tablas separadas de subtipos ni restricciones que garanticen que las banderas sean mutuamente excluyentes. La correspondencia exacta con la jerarquía del EER debe validarse contra el diagrama entregado. |
| **Atributos compuestos** (por ejemplo, `coordenadas` de región en el diagrama) | En el DDL analítico revisado, `dim_region` contiene comunidad, barrio y colonia; no incluye columnas de latitud/longitud. Las ubicaciones se documentan en otras partes del proyecto de mapa/seed, por lo que este archivo por sí solo no permite establecer la transformación completa de coordenadas. | La dimensión textual permite agrupar por divisiones territoriales. | No hay evidencia de coordenadas compuestas desglosadas en columnas de esta tabla. Si los datos espaciales son necesarios para consultas del warehouse, se debe confirmar dónde se almacenan y cómo se sincronizan. |
| **Atributos multivaluados** | No se observa una tabla de valores múltiples dedicada a roles, evidencia u otro atributo multivaluado dentro de este DDL; algunos aspectos se convierten en banderas o medidas agregadas. | Las banderas y los conteos facilitan consultas analíticas de una sola fila por miembro de dimensión o por hecho. | Se reduce el detalle de cada valor individual y no se pueden imponer las mismas restricciones que con una tabla puente normalizada. La modelación multivaluada debe comprobarse contra el EER definitivo. |
| **Atributos derivados e indicadores** | `dim_tiempo` almacena año, trimestre, mes, nombres de día y banderas; `fact_obra_mensual` almacena retraso, porcentajes y alertas. | Se simplifican filtros y consultas OLAP, y los snapshots permiten comparar indicadores por mes. | Puede existir redundancia; los valores derivados requieren una regla de cálculo y actualización consistente. No se deben sumar snapshots mensuales como si fueran hechos transaccionales independientes. |

## 3. Diferencias estructurales relevantes

### 3.1 Modelo orientado al dominio frente a modelo orientado al análisis

El EER organiza los conceptos del dominio —obra, presupuesto, informe, evidencia, ciudadano, propuesta, voto y evento de auditoría— y especifica relaciones y cardinalidades. El almacén, en cambio, separa dimensiones y tablas de hechos según el tipo de consulta: evento de auditoría o snapshot mensual por obra. Por eso una misma entidad conceptual puede alimentar una dimensión, un hecho o una combinación ETL, y una tabla dimensional puede reunir atributos de más de una entidad operacional.

### 3.2 Historia de dimensiones lentamente cambiantes

El DDL utiliza dimensiones tipo 2 para obra, región, constructora, personal y presupuesto. Cada versión tiene su clave sustituta y sus fechas de vigencia. Esto permite analizar un evento con el valor dimensional válido en ese momento. A cambio, el identificador de negocio no siempre es único en toda la tabla y las consultas deben distinguir versiones históricas de la actual.

### 3.3 Modelo de hechos con granos diferentes

`fact_eventos_auditoria` representa una fila por evento, mientras que `fact_obra_mensual` representa una combinación de tiempo y obra. La clave primaria compuesta en ambos casos refleja su grano. Los indicadores de una foto mensual no son intercambiables con los montos de una transacción y deben agregarse con cuidado.

## 4. Síntesis de lo ganado y lo perdido

- **Ganado:** análisis temporal, cruces con múltiples dimensiones, consulta más directa de métricas y seguimiento histórico mediante SCD tipo 2.
- **Perdido o trasladado fuera del esquema:** parte del detalle operacional de evidencia, votos y ciertas asociaciones; algunos enlaces entre dimensiones se dejan al proceso ETL; las reglas del modelo EER no siempre se reflejan como restricciones relacionales declaradas en este DDL.
- **Implicación:** el almacén es adecuado para análisis de seguimiento de obras, pero no sustituye por sí solo a toda la estructura operacional. Es importante documentar las reglas de carga, los granos y los mecanismos de integridad que se ejecutan fuera de las FKs.

## Fuentes consultadas

- Diagrama EER de Obras Públicas Municipales entregado/revisado en la Práctica 2.
- González Casiano, U., Maldonado Mejía, M. T., & Hurtado Avilés, G. (2026). *A Dimensional Data Warehouse for Geospatial Monitoring of Municipal Public Works, with an Evolution Path Toward a Lakehouse Architecture* [Manuscrito]. GitHub. https://github.com/gabrielhuav/PublicMunicipalWorks_DWH
- `ESQUEMA DEL DATA WAREHOUSE.sql`, rama `TestDefinitivo`, carpeta `db/arquitectura` del repositorio `PublicMunicipalWorks_DWH`. https://github.com/gabrielhuav/PublicMunicipalWorks_DWH/blob/TestDefinitivo/db/arquitectura/ESQUEMA%20DEL%20DATA%20WAREHOUSE.sql
