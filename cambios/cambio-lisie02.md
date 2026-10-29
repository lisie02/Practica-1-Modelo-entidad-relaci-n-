# Ejercicio 8. Cambio individual de esquema: predicción inteligente de retrasos

**Autora:** `lisie02`  
**Issue original:** [#3 - Propuesta: predicción inteligente de retrasos en obras públicas](https://github.com/lisie02/Practica-1-Modelo-entidad-relaci-n-/issues/3)  
**Proyecto asignado:** `PublicMunicipalWorks_DWH`

## Cambio realizado

La propuesta agrega dos tablas al esquema `warehouse`. `modelo_ia` registra el nombre y la versión de cada modelo, la fecha de entrenamiento y sus métricas de evaluación. `prediccion_riesgo` guarda cada resultado de inferencia: fecha y hora de generación, probabilidad estimada de retraso, nivel de riesgo, días estimados y factores relevantes.

La predicción contiene `tiempo_key` y `obra_key`, que forman una clave foránea compuesta hacia `fact_obra_mensual`. Así cada resultado apunta al hecho de grano obra-mes que evaluó. También almacena `id_modelo` y `version_modelo`; una clave foránea compuesta obliga a que esa versión corresponda al modelo registrado. No se reemplazan ni alteran los registros existentes de las diez dimensiones o las dos tablas de hechos.

## Regla de transformación y justificación

Se aplica la transformación de entidades fuertes a tablas independientes: `MODELO IA` y `PREDICCIÓN DE RIESGO` se convierten en `warehouse.modelo_ia` y `warehouse.prediccion_riesgo`. La relación de una obra-periodo con varias predicciones se representa mediante una relación uno-a-muchos; el modelo también puede producir muchas predicciones. La clave foránea compuesta conserva la referencia exacta al hecho mensual.

Se eligió `NUMERIC(5,4)` para `probabilidad_retraso` porque representa una probabilidad entre 0 y 1 con cuatro decimales. Un `TIMESTAMPTZ` conserva fecha, hora y zona horaria de la generación. `JSONB` permite conservar un conjunto variable de factores explicativos y métricas de evaluación. Las restricciones `CHECK` limitan la probabilidad, los niveles de riesgo y los días estimados, mientras que las claves foráneas protegen la integridad referencial.

## Efecto en los datos existentes y prueba

El script `cambio-lisie02.sql` crea las dos tablas e índices sin modificar las tablas ni las filas que ya existían; por ello no migra ni elimina hechos anteriores. Las predicciones nuevas podrán registrarse únicamente cuando la obra-periodo exista en `fact_obra_mensual` y la versión esté registrada en `modelo_ia`.

`consulta-prediccion-lisie02.sql` inserta temporalmente una versión y un resultado **demostrativos**, los consulta junto con la fecha y la obra referenciada y termina con `ROLLBACK`. Los valores de demostración no vienen de un modelo entrenado ni deben interpretarse como un resultado de IA real. Para producción se deberá sustituir esa demostración por una inferencia validada y registrar sus métricas reales.

## Límites

Este cambio implementa la estructura de almacenamiento y trazabilidad, no el entrenamiento ni la evaluación de un modelo predictivo. La propuesta original señala que se requieren datos históricos suficientes, validación con resultados conocidos y control de falsos positivos antes de usar las predicciones para tomar decisiones operativas.
