# Ejercicio 1.7. Datos y dominios del proyecto asignado

**Proyecto:** Monitoreo geoespacial de obras públicas municipales  
**Repositorio:** PublicMunicipalWorks_DWH  
**Gestor:** PostgreSQL  
**Base consultada:** `obras_publicas`  
**Fecha de revisión:** 5 de noviembre de 2026

## 1. Fuente y procedencia de los datos

El proyecto asignado utiliza un conjunto de datos sintéticos generado para probar el almacén dimensional y el prototipo de monitoreo de obras públicas.

El artículo aclara que sus cifras no proceden de registros reales del municipio de Temascaltepec. La población del almacén se construye con un generador sintético con semilla y se utiliza para evaluar la estructura, las consultas y el funcionamiento del sistema.

**Referencia del artículo en APA 7:**

González Casiano, U., Maldonado Mejía, M. T., & Hurtado Avilés, G. (2026). *A Dimensional Data Warehouse for Geospatial Monitoring of Municipal Public Works, with an Evolution Path Toward a Lakehouse Architecture* [Manuscrito]. GitHub. https://github.com/gabrielhuav/PublicMunicipalWorks_DWH

**Repositorio del equipo:**

https://github.com/lisie02/PublicMunicipalWorks_DWH

**Archivo generador:**

`scripts/generate_synthetic_data.py`

**Comando de verificación ejecutado:**

```powershell
python .\scripts\generate_synthetic_data.py --verificar
```

El generador requirió instalar las dependencias `Faker` y `psycopg2-binary`. La verificación terminó correctamente y confirmó las cifras declaradas por el propio programa. Esta opción comprueba los totales del escenario, pero no ejecuta una nueva carga en PostgreSQL.

## 2. Características del conjunto

El conjunto se almacena en PostgreSQL, separado en un esquema operacional (`public`) y un esquema dimensional (`warehouse`).

No se trata de un único archivo CSV: el proyecto utiliza un generador que produce información estructurada para las tablas del sistema. El repositorio contiene el código fuente que permite reproducir el escenario sintético.

### 2.1 Cifras declaradas por el generador

| Elemento | Registros o valor |
|---|---:|
| Obras | 1,247 |
| Comunidades | 55 |
| Presupuesto acumulado | $127,400,000 MXN |
| Evidencias | 3,421 |
| Eventos de auditoría iniciales | 8,934 |
| Propuestas | 2,156 |
| Votos | 8,723 |
| Informes de avance | 14,885 |
| Hechos mensuales | 29,928 |

El artículo distingue tres poblaciones sintéticas: la demostración web, el almacén de prueba y el conjunto separado para evaluar la detección de anomalías. No deben mezclarse sus registros ni sus cifras.

### 2.2 Estructura general de la información

El almacén contiene diez dimensiones y dos tablas de hechos.

Las dimensiones son:

- `dim_tiempo`
- `dim_tipo_evento`
- `dim_obra`
- `dim_region`
- `dim_constructora`
- `dim_personal`
- `dim_fuente`
- `dim_presupuesto`
- `dim_poblador`
- `dim_propuesta`

Las tablas de hechos son:

- `fact_eventos_auditoria`: una fila por evento de auditoría.
- `fact_obra_mensual`: una fila por combinación de obra y mes.

La tabla mensual almacena indicadores como presupuesto, costo acumulado, saldo, avance físico, avance presupuestario, días de retraso, informes registrados, imágenes de evidencia y permisos obtenidos.

## 3. Comparación entre el artículo y la base PostgreSQL

Se consultó la base `obras_publicas`, alojada en el contenedor `obras-publicas-db-1`.

### 3.1 Comparación de los indicadores principales

| Indicador | Referencia del artículo/generador | PostgreSQL | Observación |
|---|---:|---:|---|
| Obras | 1,247 | 1,247 | Coincide |
| Propuestas | 2,156 | 2,156 | Coincide |
| Votos | 8,723 | 8,723 | Coincide |
| Informes | 14,885 | 14,885 | Coincide |
| Hechos mensuales | 29,928 | 29,928 | Coincide |
| Presupuesto acumulado | $127,400,000.00 | $127,400,000.00 | Coincide |
| Presupuesto medio | $102,165 aprox. | $102,165.20 | Coincide por redondeo |
| Evidencias | 3,421 | 3,421 en la suma de snapshots | Coincidencia numérica; falta verificar metadatos |

La tabla `public.obra` contiene 1,247 registros y 1,247 identificadores distintos. La tabla `public.presupuesto_obra` contiene también 1,247 registros.

El presupuesto acumulado se calculó con:

```sql
SELECT
    COUNT(*) AS presupuestos,
    SUM(presupuesto_total) AS presupuesto_acumulado,
    ROUND(AVG(presupuesto_total), 2) AS presupuesto_promedio,
    MIN(presupuesto_total) AS presupuesto_minimo,
    MAX(presupuesto_total) AS presupuesto_maximo
FROM public.presupuesto_obra;
```

El total obtenido coincide con los $127.4 millones declarados por el artículo.

### 3.2 Diferencias en los presupuestos individuales

| Indicador | Generador | PostgreSQL |
|---|---:|---:|
| Mínimo | $9,912 | $9,783.35 |
| Máximo | $1,020,150 | $1,006,870.78 |
| Promedio | $102,165 aprox. | $102,165.20 |

Aunque la suma total coincide, los valores mínimo y máximo no son idénticos. Por ello, la coincidencia del presupuesto acumulado no demuestra que todos los registros individuales sean iguales a los del generador.

Esta diferencia queda pendiente de revisar a nivel de cada obra y de la versión del conjunto cargado.

## 4. Análisis de eventos de auditoría

La tabla `warehouse.fact_eventos_auditoria` contiene 55,740 registros.

El artículo reporta 8,934 eventos escritos directamente por el escenario inicial y aproximadamente 28,000 en una instancia poblada con eventos adicionales generados por disparadores.

En PostgreSQL se encontraron:

| Indicador | Resultado |
|---|---:|
| Eventos totales | 55,740 |
| `es_evento_inicial = TRUE` | 1,818 |
| Otros eventos | 53,922 |

La distribución por año fue:

| Año | Eventos |
|---|---:|
| 2024 | 8,817 |
| 2025 | 8,840 |
| 2026 | 38,083 |
| **Total** | **55,740** |

Los registros de 2026 coinciden por tipo con los conteos de algunas tablas operacionales:

| Tipo de evento en 2026 | Eventos | Registros operacionales |
|---|---:|---:|
| Creación de obra | 1,247 | 1,247 obras |
| Informe de avance | 14,885 | 14,885 informes |
| Registro de costo | 13,228 | 13,228 costos |
| Voto emitido | 8,723 | 8,723 votos |

Sin embargo, la tabla completa de auditoría tiene más filas que las aproximadamente 28,000 reportadas en el artículo. Los registros de 2024 y 2025 y las diferencias por tipo requieren una revisión adicional antes de atribuirles una causa.

La columna `es_evento_inicial` tampoco puede utilizarse para identificar directamente los 8,934 eventos iniciales del artículo: en esta base devuelve 1,818 registros, cifra que coincide con los eventos de creación de obra.

## 5. Revisión de evidencias fotográficas

Se obtuvieron tres resultados distintos:

| Consulta | Resultado |
|---|---:|
| `public.imagenes_informe` | 0 registros |
| Suma de `warehouse.fact_obra_mensual.imagenes_evidencia` | 3,421 |
| Eventos de tipo `SUBIDA_IMAGEN` | 497 |

La suma de imágenes en los snapshots coincide numéricamente con el artículo, pero la tabla operacional de metadatos está vacía y los eventos de auditoría no contienen URL de evidencia.

Por ello, se puede afirmar que el almacén contiene el indicador agregado de 3,421 evidencias, pero no que estén disponibles los 3,421 archivos o sus metadatos individuales.

## 6. Diferencias entre informes, costos y eventos

La comparación entre las tablas operacionales y los eventos de auditoría mostró:

| Elemento | Tabla operacional | Eventos de auditoría | Diferencia |
|---|---:|---:|---:|
| Informes de avance | 14,885 | 15,410 | +525 |
| Costos | 13,228 | 13,734 | +506 |
| Votos | 8,723 | 17,993 | +9,270 |

Estas diferencias muestran que los eventos de auditoría no pueden interpretarse como un conteo directo de registros operacionales únicos.

No se concluye que todos sean duplicados, porque se necesita revisar su correspondencia por identificador, fecha y tipo de evento.

## 7. Periodo cubierto

| Tabla o conjunto | Fecha inicial | Fecha final |
|---|---|---|
| Hechos mensuales | 2024-01-01 | 2025-12-01 |
| Eventos de auditoría | 2024-01-01 | 2026-10-06 |

La tabla de hechos mensuales contiene dos años de información, mientras que los eventos de auditoría llegan hasta octubre de 2026.

Esto debe considerarse al comparar el contenido de ambas tablas y los resultados presentados en el artículo.

## 8. Problemas y decisiones de calidad de datos

| Situación observada | Decisión |
|---|---|
| Los presupuestos mínimo y máximo no coinciden con la verificación del generador, aunque el total sí coincide. | Conservar los valores existentes y documentar la diferencia; no modificar importes sin identificar el registro y su procedencia. |
| Existen más eventos de auditoría que los descritos en el artículo. | Conservarlos y revisar la correspondencia por tipo, año e identificador antes de decidir si son duplicados. |
| La tabla operacional de imágenes está vacía. | No inventar metadatos ni archivos; documentar que solo coincide la suma agregada de los snapshots. |
| Los eventos de informes, costos y votos superan los conteos operacionales. | No eliminarlos automáticamente; requieren una auditoría de correspondencia. |
| La suma de `informes_registrados` en snapshots es 172,937, mayor que los 14,885 informes operacionales. | No interpretar la suma de snapshots como informes únicos; son medidas repetidas en el tiempo y deben analizarse según el grano mensual. |

No se eliminaron registros ni se cambiaron restricciones durante estas consultas.

## 9. Limitaciones del análisis

La comparación se realizó sobre los conteos, sumas y distribuciones disponibles en PostgreSQL. No se verificó la correspondencia individual de las 1,247 obras contra una regeneración completa del conjunto.

El comando `--verificar` confirmó las cifras declaradas por el generador, pero no ejecutó una nueva carga en la base de datos.

Por tanto, las coincidencias agregadas permiten comprobar que la base conserva varios totales de referencia, pero las diferencias de presupuestos individuales, auditoría y evidencias requieren una revisión más profunda.

## 10. Conclusión

El proyecto asignado utiliza una población sintética creada para probar el monitoreo geoespacial y el análisis de obras públicas municipales. La verificación del generador confirmó las cifras declaradas por sus autores y la base PostgreSQL coincide con varios indicadores principales: obras, propuestas, votos, informes, hechos mensuales y presupuesto acumulado.

También se encontraron diferencias en los valores mínimo y máximo de los presupuestos, en el número de eventos de auditoría y en la disponibilidad de metadatos de imágenes. Estas diferencias no deben corregirse eliminando datos sin una revisión de su origen.

En conclusión, la base contiene una población que coincide en varios totales con el escenario publicado, pero no se puede afirmar que todos sus registros sean una reproducción exacta del conjunto de referencia. Los datos son sintéticos y no representan la ejecución real de obras públicas en Temascaltepec.

## 11. Restricciones de dominio adicionales propuestas

Después de revisar las restricciones existentes, se propusieron tres validaciones adicionales. Se aplicaron únicamente en la copia `obras_publicas_pruebas`, sin modificar la base original.

### 11.1 Reglas propuestas

| N.º | Tabla | Restricción | Justificación |
|---|---|---|---|
| 1 | `public.presupuesto_obra` | `presupuesto_total >= 0` | Un presupuesto asignado no puede ser negativo. |
| 2 | `public.costos` | `costo >= 0` | Un costo registrado debe ser cero o positivo. |
| 3 | `warehouse.fact_obra_mensual` | Avances físico y presupuestario entre 0 y 100 | Los porcentajes acumulados no pueden ser inferiores a 0 ni superiores a 100. |

### 11.2 Comprobación previa de los datos

Antes de aplicar las restricciones, se consultaron los registros existentes en la base original.

| Validación | Registros inválidos encontrados |
|---|---:|
| Presupuestos negativos | 0 |
| Costos negativos | 0 |
| Avance físico fuera del intervalo 0–100 | 0 |
| Avance presupuestario fuera del intervalo 0–100 | 0 |

Los resultados indicaron que los datos existentes cumplían las tres reglas propuestas.

### 11.3 Implementación

Se creó el archivo `001-restricciones-propuestas.sql` con las siguientes restricciones:

```sql
ALTER TABLE public.presupuesto_obra
ADD CONSTRAINT chk_presupuesto_total_no_negativo
CHECK (presupuesto_total >= 0);

ALTER TABLE public.costos
ADD CONSTRAINT chk_costo_no_negativo
CHECK (costo >= 0);

ALTER TABLE warehouse.fact_obra_mensual
ADD CONSTRAINT chk_avances_mensuales_rango
CHECK (
    (avance_fisico_acumulado IS NULL
     OR avance_fisico_acumulado BETWEEN 0 AND 100)
    AND
    (avance_presup_acumulado IS NULL
     OR avance_presup_acumulado BETWEEN 0 AND 100)
);
```

Las tres restricciones se aplicaron correctamente en `obras_publicas_pruebas`. Una consulta posterior confirmó la existencia de las tres.

También se verificó que los mismos nombres de restricciones no existieran en `obras_publicas`, lo que permitió comprobar que la base original permaneció separada de las pruebas.

### 11.4 Pruebas de funcionamiento

Se realizaron cuatro pruebas dentro de una transacción que terminó con `ROLLBACK`.

| Prueba | Operación intentada | Restricción que rechazó el valor | Resultado |
|---|---|---|---|
| 1 | Asignar -1 al presupuesto de una obra | `chk_presupuesto_total_no_negativo` | Correcto |
| 2 | Asignar -1 al costo de un registro | `chk_costo_no_negativo` | Correcto |
| 3 | Asignar 101 al avance físico | `chk_avances_mensuales_rango` | Correcto |
| 4 | Asignar -1 al avance presupuestario | `chk_avances_mensuales_rango` | Correcto |

Los mensajes de PostgreSQL confirmaron:

```text
new row for relation "presupuesto_obra" violates check constraint
"chk_presupuesto_total_no_negativo"

new row for relation "costos" violates check constraint
"chk_costo_no_negativo"

new row for relation "fact_obra_mensual" violates check constraint
"chk_avances_mensuales_rango"
```

La cuarta prueba produjo nuevamente el rechazo de `chk_avances_mensuales_rango`, esta vez por el avance presupuestario negativo.

Al finalizar apareció:

```text
ROLLBACK
FIN: pruebas terminadas. Los cambios fueron revertidos.
```

### 11.5 Conclusión de las restricciones adicionales

Las pruebas demostraron que las tres restricciones propuestas funcionan en la copia de la base de datos. PostgreSQL impidió registrar presupuestos y costos negativos, así como porcentajes de avance fuera del intervalo permitido.

La comparación previa indicó que los registros existentes cumplían estas reglas, por lo que su implementación no provocó el rechazo de datos válidos. El uso de una copia y de `ROLLBACK` permitió experimentar sin alterar la información original.

