# Ejercicio 1.4. Carga automatizada de EcoData

## 1. Objetivo

Implementar un proceso de carga de datos que permita incorporar los resultados del estudio UANL a EcoData, evitando duplicados y conservando la integridad de la información.

## 2. Archivos desarrollados

- `datos/envases_355ml.csv`: contiene los tres registros extraídos de la Tabla III del artículo.
- `poblar/poblar.sql`: valida e integra los registros mediante PostgreSQL.
- `poblar/poblar.ps1`: automatiza la copia de archivos y la ejecución del SQL.

## 3. Características del proceso

**Repetible:** utiliza comprobaciones `NOT EXISTS` para no duplicar registros que ya están almacenados.

**Ordenado:** procesa primero los catálogos y fuentes, después los productos, las relaciones producto-material y finalmente los impactos ambientales.

**Transaccional:** utiliza `BEGIN` y `COMMIT`. Si ocurre un error, PostgreSQL interrumpe la operación y revierte la transacción.

**Validación:** revisa que los materiales sean reconocidos y que los indicadores numéricos no sean negativos o nulos.

**Sin credenciales en el código:** utiliza las variables de entorno `PGUSER` y `PGDATABASE`.

**Carga masiva:** utiliza `\copy` de PostgreSQL para importar el archivo CSV a una tabla temporal.

## 4. Primera ejecución

La primera ejecución terminó correctamente con `COMMIT`.

Los tres productos, sus materiales y sus impactos ya existían en la base de datos. Por ello, el proceso reconoció los registros y evitó duplicarlos.

## 5. Segunda ejecución

Se ejecutó nuevamente el mismo programa, sin modificar el CSV ni el esquema.

| Tabla | Filas del archivo | Insertadas | Omitidas | Rechazadas |
|---|---:|---:|---:|---:|
| categoria | 1 | 0 | 1 | 0 |
| fuente | 1 | 0 | 1 | 0 |
| material | 3 | 0 | 3 | 0 |
| producto | 3 | 0 | 3 | 0 |
| producto_material | 3 | 0 | 3 | 0 |
| impacto_ambiental | 3 | 0 | 3 | 0 |
| **Total** | **14** | **0** | **14** | **0** |

La segunda ejecución finalizó correctamente y no agregó registros duplicados.

## 6. Verificación de los conteos

Después de ejecutar el programa se consultaron los registros de las tablas:

| Tabla | Registros encontrados |
|---|---:|
| categoria | 3 |
| fuente | 3 |
| material | 4 |
| producto | 3 |
| producto_material | 3 |
| impacto_ambiental | 3 |

Los conteos se mantuvieron estables después de la segunda ejecución.

## 7. Consideraciones sobre la fuente

El archivo contiene tres materiales y cuatro indicadores ambientales.

La energía total y la huella de carbono se incorporan a EcoData. La acidificación y la eutrofización se conservan en el CSV original, pero no se cargan porque el esquema actual no tiene columnas específicas para esos indicadores.

No se asignaron valores de precio, vida útil, país de fabricación ni reciclabilidad sin evidencia documental.

## 8. Conclusión

El proceso de carga automatizada funcionó correctamente en dos ejecuciones. PostgreSQL reconoció los datos existentes, evitó duplicados y confirmó las operaciones mediante transacciones.

El programa puede repetirse utilizando un único comando de PowerShell, conserva las credenciales fuera del repositorio y permite incorporar los datos publicados sin alterar los registros que ya existían.

## 9. Prueba de rechazo y reversión de la transacción

Se realizó una prueba adicional para comprobar el comportamiento del proceso ante datos inválidos.

### Operación realizada

Se agregó temporalmente al CSV el siguiente registro:

| Material | Energía (MJ) | Huella de carbono | Resultado |
|---|---:|---:|---|
| Plomo | 1 | 0.1 | Rechazado |

Este registro se utilizó exclusivamente para comprobar la validación. No proviene de la fuente científica.

### Resultado del gestor

PostgreSQL detectó el material no reconocido y canceló la carga:

`Carga cancelada: material=Plomo: material no reconocido`

La transacción no llegó a insertar los registros.

### Comprobación de la reversión

| Tabla | Registros antes | Registros después |
|---|---:|---:|
| producto | 3 | 3 |
| impacto_ambiental | 3 | 3 |
| producto_material | 3 | 3 |

Los conteos permanecieron iguales, por lo que no se produjeron modificaciones parciales.

El CSV original se restauró después de finalizar la prueba.

**Conclusión:** el proceso identificó el dato inválido, detuvo la operación y conservó la información previamente almacenada.

## 10. Comparación de rendimiento: COPY e INSERT individual

Se compararon dos métodos para cargar los tres registros del archivo `envases_355ml.csv`, utilizando tablas temporales para evitar modificar las tablas permanentes de EcoData.

### Resultados obtenidos

| Método | Registros cargados | Tiempo medido |
|---|---:|---:|
| COPY | 3 | 3.277 ms |
| INSERT individual 1 | 1 | 5.117 ms |
| INSERT individual 2 | 1 | 0.466 ms |
| INSERT individual 3 | 1 | 0.148 ms |
| **INSERT individual total** | **3** | **5.731 ms** |

### Análisis

La suma de los tres INSERT individuales fue de 5.731 ms, mientras que COPY registró 3.277 ms.

La diferencia fue de 2.454 ms. En esta prueba, COPY presentó aproximadamente 42.8 % menos tiempo que la suma de los INSERT individuales.

### Limitaciones

La comparación se realizó con solamente tres registros. Los tiempos corresponden a una ejecución y pueden variar según la carga del equipo y el entorno de PostgreSQL.

Por esta razón, los resultados demuestran el funcionamiento de ambos métodos, pero no permiten establecer una conclusión definitiva sobre el rendimiento para grandes volúmenes.

### Integridad de los datos

Ambos métodos cargaron tres registros en sus respectivas tablas temporales. Al finalizar se ejecutó ROLLBACK, evitando modificar las tablas permanentes de EcoData.

## 11. Conclusión general del ejercicio 1.4

Se desarrolló un proceso automatizado que utiliza un archivo CSV y un programa de PowerShell para ejecutar instrucciones SQL en PostgreSQL.

Se comprobó que la carga puede ejecutarse dos veces sin duplicar registros, que los datos inválidos son rechazados y que la transacción conserva la información original cuando ocurre un error.

También se compararon COPY e INSERT individual. En la prueba realizada, COPY obtuvo un menor tiempo de ejecución.

El proceso cumple con las pruebas realizadas de repetibilidad, orden de dependencias, validación, transacción, conteo de resultados, variables de entorno y carga masiva.
