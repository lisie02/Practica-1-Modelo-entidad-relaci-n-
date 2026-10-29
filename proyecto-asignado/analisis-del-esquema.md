# Ejercicio 7.1 y 7.2. Análisis del esquema del proyecto asignado

**Proyecto asignado:** *A Dimensional Data Warehouse for Geospatial Monitoring of Municipal Public Works* (`PublicMunicipalWorks_DWH`)  
**Materia:** Bases de Datos — Práctica 3  
**Fuente técnica principal:** `db/arquitectura/ESQUEMA DEL DATA WAREHOUSE.sql`, rama `TestDefinitivo` del repositorio público.

## 1. Alcance del análisis

Se revisó el DDL del almacén dimensional publicado en `PublicMunicipalWorks_DWH`. El archivo define diez dimensiones y dos tablas de hechos en el esquema `warehouse`: `dim_tiempo`, `dim_tipo_evento`, `dim_obra`, `dim_region`, `dim_constructora`, `dim_personal`, `dim_fuente`, `dim_presupuesto`, `dim_poblador`, `dim_propuesta`, `fact_eventos_auditoria` y `fact_obra_mensual`.

Este DDL es un modelo analítico dimensional, no un esquema transaccional que replique literalmente el diagrama EER. Por eso se interpreta a partir del grano de las tablas de hechos, las dimensiones, las claves sustitutas y las reglas de historia de dimensiones lentamente cambiantes (SCD). Las observaciones de este documento se limitan al DDL citado; otras partes del sistema pueden almacenar datos operacionales o evidencias que no aparecen en este archivo.

## 2. Regla de transformación y lectura general

La regla básica «entidad fuerte → tabla» se reconoce en las dimensiones. Sin embargo, el diseño la adapta para consultas analíticas: las dimensiones tienen claves sustitutas (`*_key`) y conservan identificadores del dominio (`*_id`) cuando corresponde; las tablas de hechos almacenan eventos o fotografías mensuales y referencian las dimensiones mediante claves foráneas. En dimensiones de tipo 2 se conservan varias versiones históricas del mismo identificador de negocio.

### 2.1 Inventario tabla por tabla

| Tabla | Función y regla que explica su estructura | Clave primaria y claves foráneas declaradas | Restricciones relevantes |
|---|---|---|---|
| `warehouse.dim_tiempo` | Dimensión calendario. Los componentes de fecha (año, trimestre, mes, día, semana y banderas) se materializan para filtrar y agrupar con facilidad. Es SCD tipo 0. | PK `tiempo_key`. No declara FK. | `fecha` es `NOT NULL UNIQUE`; varios componentes temporales son `NOT NULL`; `es_electoral` y `es_cierre_ejercicio` tienen `DEFAULT FALSE`; `creado_en DEFAULT NOW()`. La función `generar_dim_tiempo` genera fechas entre 2020 y 2030 y usa la forma `YYYYMMDD` para la clave. |
| `warehouse.dim_tipo_evento` | Catálogo de clasificación de eventos de auditoría, equivalente a una entidad de tipo/categoría. SCD tipo 0. | PK `tipo_evento_key` (`SERIAL`). No declara FK. | `codigo_evento VARCHAR(50) NOT NULL UNIQUE`; `nombre_evento` y `categoria` son obligatorios; valores predeterminados en importancia y banderas booleanas; índice por categoría. |
| `warehouse.dim_obra` | Dimensión principal de obra; incorpora atributos descriptivos y referencias analíticas a región, constructora y supervisor. SCD tipo 2 para conservar versiones. | PK `(obra_key)`. No declara FK para `constructora_key`, `region_key` ni `supervisor_key` en este DDL. | `obra_id` y `codigo_expediente` son `NOT NULL`; `fecha_efectiva` y `fecha_expiracion` son `NOT NULL` con valores predeterminados; `es_actual NOT NULL DEFAULT TRUE`; índice por identificador y parcial por versiones actuales. `obra_id` no se declara `UNIQUE`, lo que permite varias versiones. |
| `warehouse.dim_region` | Dimensión geográfica y de comunidad/barrio. SCD tipo 2. | PK `region_key`. No declara FK. | `region_id`, `comunidad` y `barrio` son `NOT NULL`; `colonia` es opcional; fechas de vigencia y `es_actual` tienen predeterminados. `region_id` no es único porque pueden existir versiones históricas. |
| `warehouse.dim_constructora` | Dimensión de empresa/constructora contratista. SCD tipo 2. | PK `constructora_key`. No declara FK. | `constructora_id` es `NOT NULL`; `nombre_const` y `tipo_ejecutor` son `NOT NULL`; `rfc` es opcional; fechas de vigencia y `es_actual` permiten gestionar historial. `constructora_id` no es `UNIQUE`. |
| `warehouse.dim_personal` | Dimensión de personal técnico; combina identidad, rol y banderas de roles del sistema. SCD tipo 2. | PK `personal_key`. No declara FK. | `personal_id`, `nombre_completo` y `rol` son `NOT NULL`; las banderas de rol tienen `DEFAULT FALSE`; mantiene fechas de vigencia y marca de versión actual. Incluye índices por identificador y rol. |
| `warehouse.dim_fuente` | Dimensión de fuente presupuestaria. SCD tipo 1: conserva el último valor, con métricas acumuladas. | PK `fuente_key`. No declara FK. | `fuente_id` es `NOT NULL UNIQUE`; `grado_nivel` y `programa` son obligatorios; contadores y montos acumulados tienen `DEFAULT 0`; marcas de creación/actualización usan `NOW()`. |
| `warehouse.dim_presupuesto` | Dimensión de presupuesto. Conserva versiones para análisis histórico (SCD tipo 2). | PK `presupuesto_key`. No declara FK para `proyectista_key`. | `presupuesto_id` y `presupuesto_total` son `NOT NULL`; el total es `NUMERIC(15,2)`; `proyectista_key` es opcional; fechas de vigencia y `es_actual` tienen valores predeterminados. `presupuesto_id` no es `UNIQUE`. |
| `warehouse.dim_poblador` | Dimensión de ciudadano/poblador. SCD tipo 1: sobrescribe correcciones del estado actual en vez de conservar un histórico de datos personales. | PK `poblador_key`. No declara FK. | `poblador_id INTEGER NOT NULL UNIQUE`; `nombre_completo` y `comunidad` son `NOT NULL`; `curp` es opcional; creación y actualización tienen `DEFAULT NOW()`. |
| `warehouse.dim_propuesta` | Dimensión de propuestas ciudadanas, con campos descriptivos reunidos en una sola tabla. SCD tipo 1. | PK `propuesta_key`. No declara FK para `poblador_key`. | `propuesta_id INTEGER NOT NULL UNIQUE`; `titulo` y `region` son `NOT NULL`; las descripciones, `anio_convocatoria` y `poblador_key` son opcionales; marcas de tiempo por defecto. |
| `warehouse.fact_eventos_auditoria` | Tabla de hechos de grano evento de auditoría. Relaciona el evento con dimensiones y contiene medidas y contexto del evento. Está particionada por rango de `tiempo_key`. | PK compuesta `(tiempo_key, evento_key)`. FKs: `tiempo_key → dim_tiempo`, `tipo_evento_key → dim_tipo_evento`, y opcionales `obra_key`, `region_key`, `personal_key`, `constructora_key`, `fuente_key`, `presupuesto_key`, `poblador_key`, `propuesta_key` hacia sus dimensiones correspondientes. | `tiempo_key` y `tipo_evento_key` son `NOT NULL`; otras referencias se permiten nulas. Incluye montos, porcentajes, días transcurridos, votos, banderas, descripción, documento/url y metadatos de sesión/red. `usuario_db DEFAULT CURRENT_USER`. Se declaran particiones para 2024, 2025 y 2026 e índices por algunas dimensiones. |
| `warehouse.fact_obra_mensual` | Tabla de hechos de grano obra-mes (snapshot mensual), con medidas acumuladas de presupuesto, costo y avance. | PK compuesta `(tiempo_key, obra_key)`. FKs obligatorias hacia `dim_tiempo` y `dim_obra`. | Ambas claves son `NOT NULL`; registra montos, porcentajes acumulados, días de retraso, cantidad de informes/imágenes/permisos y banderas de retraso/alertas. Índices por obra y por retraso positivo. |

### 2.2 Claves y restricciones observadas

- **Claves sustitutas:** la mayoría de las dimensiones utilizan `SERIAL` o `BIGSERIAL` para sus claves analíticas, separadas del identificador de negocio.
- **Claves únicas:** `dim_tiempo.fecha`, `dim_tipo_evento.codigo_evento`, `dim_fuente.fuente_id`, `dim_poblador.poblador_id` y `dim_propuesta.propuesta_id` se declaran únicas.
- **Claves foráneas:** las relaciones declaradas se concentran en las dos tablas de hechos. En las dimensiones, campos como `dim_obra.constructora_key`, `dim_obra.region_key`, `dim_obra.supervisor_key`, `dim_presupuesto.proyectista_key` y `dim_propuesta.poblador_key` no están declarados como FKs en el DDL revisado.
- **Acciones referenciales:** el archivo no especifica `ON DELETE` ni `ON UPDATE` en las FKs observadas; por tanto, se aplica el comportamiento predeterminado del gestor.
- **Restricciones de dominio:** se emplean `NOT NULL`, `UNIQUE` y `DEFAULT`; no se observan en este fragmento `CHECK` para limitar porcentajes, montos no negativos o intervalos de vigencia.

## 3. Dónde se aparta de una transformación EER estricta

### Decisión 1. Desnormalización analítica de dimensiones

El esquema agrupa atributos con fines de consulta. Por ejemplo, `dim_personal` junta `rol` con banderas `es_supervisor`, `es_proyectista`, `es_director` y `es_secretario`; `dim_propuesta` conserva `region` y varios textos descriptivos; `dim_obra` mantiene claves de constructora, región y supervisor como atributos de dimensión. En un modelo transaccional más normalizado, parte de estos datos podría residir en entidades relacionadas.

**Qué se gana:** consultas analíticas con menos uniones y una estructura cercana al esquema estrella. **Qué se pierde o cuesta:** se repite información, las reglas entre atributos no quedan siempre garantizadas por FKs y las actualizaciones requieren cuidado para no dejar datos inconsistentes.

### Decisión 2. Claves sustitutas e historial SCD tipo 2

En dimensiones como `dim_obra`, `dim_region`, `dim_constructora`, `dim_personal` y `dim_presupuesto`, el diseño utiliza una clave sustituta y campos de vigencia (`fecha_efectiva`, `fecha_expiracion`, `es_actual`). El identificador de negocio puede repetirse entre versiones, como ocurre con `obra_id` en `dim_obra`.

**Qué se gana:** se conserva el estado histórico de una dimensión y es posible analizar hechos respecto de la versión vigente en un momento concreto. **Qué se pierde o cuesta:** una entidad de negocio puede tener varias filas; las consultas deben elegir la versión correcta y no pueden asumir que el identificador de negocio determina una sola fila.

### Decisión 3. Tablas de hechos con distinto grano y datos acumulados

`fact_eventos_auditoria` representa eventos individuales, mientras que `fact_obra_mensual` guarda un snapshot por obra y tiempo. La segunda tabla mantiene valores acumulados, como presupuesto, costo, saldo y avance, además de indicadores de retraso y alerta.

**Qué se gana:** se facilitan tanto las consultas de eventos como las comparaciones mensuales. **Qué se pierde o cuesta:** las medidas acumuladas pueden repetir información derivada; deben definirse reglas para no sumar snapshots de meses diferentes como si fueran transacciones independientes.

### Decisión 4. Integridad referencial incompleta en algunas dimensiones

El DDL declara FKs desde las tablas de hechos, pero no las declara para varias claves almacenadas dentro de dimensiones. Por ejemplo, `dim_obra` tiene `constructora_key`, `region_key` y `supervisor_key` sin FK explícita, y `dim_propuesta` contiene `poblador_key` sin FK explícita.

**Qué se gana:** el ETL puede cargar dimensiones por etapas y resolver las claves en distintos momentos. **Qué se pierde o cuesta:** PostgreSQL no verifica por medio de esas columnas que el registro de dimensión referenciado exista; se necesita validar la integridad durante la carga y con consultas de calidad de datos.

## 4. Conclusión del análisis

El esquema es coherente con un almacén dimensional: separa dimensiones descriptivas y hechos con distintos granos, utiliza claves sustitutas, maneja historia de dimensiones mediante SCD y materializa indicadores para análisis. No debe interpretarse como una traducción literal del EER operacional: es una estructura analítica que introduce desnormalización, snapshots e historia. La comparación con el EER debe reconocer tanto las ventajas para análisis temporal como las relaciones y detalles que este DDL no representa de manera explícita.

## Fuentes consultadas

- González Casiano, U., Maldonado Mejía, M. T., & Hurtado Avilés, G. (2026). *A Dimensional Data Warehouse for Geospatial Monitoring of Municipal Public Works, with an Evolution Path Toward a Lakehouse Architecture* [Manuscrito]. GitHub. https://github.com/gabrielhuav/PublicMunicipalWorks_DWH
- `ESQUEMA DEL DATA WAREHOUSE.sql`, rama `TestDefinitivo`, carpeta `db/arquitectura` del repositorio `PublicMunicipalWorks_DWH`. https://github.com/gabrielhuav/PublicMunicipalWorks_DWH/blob/TestDefinitivo/db/arquitectura/ESQUEMA%20DEL%20DATA%20WAREHOUSE.sql
