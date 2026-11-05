# Ejercicio 1.3. Fuente de datos del proyecto propio

**Proyecto:** EcoData: Base de datos para medir el impacto ambiental de productos cotidianos.  
**Unidad de aprendizaje:** Bases de Datos.  
**Práctica:** 4.  
**Gestor:** PostgreSQL.  
**Rama de trabajo:** `practica4-5`.

## 1. Selección de la fuente de datos

Para el proyecto EcoData se seleccionó un estudio científico publicado por la Universidad Autónoma de Nuevo León (UANL), en la revista *Ingenierías*, que analiza el impacto ambiental de tres materiales utilizados en envases de refrescos de 355 ml: PET, vidrio y aluminio.

El estudio utiliza la metodología de Análisis de Ciclo de Vida mediante SolidWorks Sustainability y compara distintos impactos ambientales asociados a los materiales de envasado.

La selección de esta fuente se relaciona directamente con el objetivo de EcoData, porque permite registrar y comparar indicadores ambientales de productos cotidianos a partir de información publicada.

### Referencia en formato APA 7

Cabriales Gómez, R. C., Arroyo Mayorga, Y. M., Cobos Zaleta, D., & Reyes Osorio, L. A. (2024). Sustentabilidad de materiales para el envasado de refrescos implementando un Análisis de Ciclo de Vida mediante SolidWorks Sustainability. *Ingenierías, 27*(96), 11–26. https://doi.org/10.29105/ingenierias27.96-947

**Enlaces de consulta:**

- Página del artículo: https://ingenierias.uanl.mx/index.php/i/article/view/947
- Documento PDF: https://ingenierias.uanl.mx/index.php/i/article/download/947/1284
- DOI: https://doi.org/10.29105/ingenierias27.96-947

**Fecha de consulta y verificación:** 5 de noviembre de 2026.

### Licencia y condiciones de uso

La revista indica que el artículo se encuentra disponible bajo la licencia Creative Commons Atribución 4.0 Internacional (CC BY 4.0).

Esta licencia permite compartir y adaptar el contenido, incluso con fines comerciales, siempre que se reconozca la autoría original, se incluya un enlace a la licencia y se indiquen las modificaciones realizadas.

Licencia: https://creativecommons.org/licenses/by/4.0/

Para utilizar los resultados en EcoData se conserva la referencia bibliográfica de los autores y se identifica que los valores fueron extraídos de la Tabla III del artículo.

## 2. Formato original, tamaño y cantidad de registros

### Formato

La fuente original es un artículo científico digital en formato PDF. Los resultados utilizados se encuentran en la Tabla III, titulada:

*Comparativa de resultados para caso de estudio I (análisis nacional) de impactos medioambientales asociados a cada material.*

El artículo comprende las páginas impresas 11 a 26 de la revista, equivalentes a 16 páginas.

La ficha editorial no indica el tamaño exacto del archivo PDF en bytes y tampoco proporciona la tabla como un archivo CSV o XLSX independiente.

### Cantidad de registros y campos

La tabla seleccionada contiene tres materiales y cuatro indicadores ambientales. Al organizar los datos en formato tabular para EcoData se obtienen:

- 3 observaciones, una por cada material de envasado.
- 4 indicadores ambientales por observación.
- 12 valores numéricos de impacto ambiental.

Los materiales incluidos son:

1. Vidrio.
2. Aluminio.
3. PET.

Los indicadores ambientales son:

1. Huella de carbono.
2. Energía total consumida.
3. Acidificación atmosférica.
4. Eutrofización del agua.

### Datos transcritos de la Tabla III

| Material | Huella de carbono (kg CO2e) | Energía total (MJ) | Acidificación (mol H+ e) | Eutrofización (kg N e) |
|---|---:|---:|---:|---:|
| Vidrio | 0.813 | 7.6 | 0.172 | 0.00024 |
| Aluminio | 0.301 | 5.1 | 0.078 | 0.000036 |
| PET | 0.095 | 1.8 | 0.017 | 0.000012 |

Los valores de eutrofización se expresaron en notación decimal para facilitar su manejo y comparación, conservando el valor numérico de la publicación.

La tabla corresponde al Caso de estudio I, que representa el análisis nacional de los envases estudiados.

## 3. Correspondencia entre los campos de la fuente y el esquema de EcoData

La correspondencia se realizó considerando las nueve tablas del modelo relacional actual.

| Campo o elemento de la fuente | Tabla de EcoData | Columna de destino | Transformación o justificación |
|---|---|---|---|
| PET, vidrio y aluminio | material | nombre | Se registran como nombres normalizados de los materiales. |
| Descripción del material | material | descripcion | Se puede complementar con una descripción documental del material, sin atribuirle datos no publicados. |
| Familia del material | material | tipo | Se utiliza la clasificación interna del proyecto cuando corresponde; no es un campo independiente de la Tabla III. |
| Reciclabilidad | material | reciclable | No se asigna directamente porque la tabla no proporciona una condición booleana de reciclabilidad por material. |
| Envase de refresco de 355 ml | producto | nombre | Se construye un nombre descriptivo para identificar cada presentación. |
| Marca Coca-Cola | producto | marca | El artículo identifica los envases analizados como utilizados por Coca-Cola. |
| Precio | producto | precio_aproximado | No se proporciona en la tabla; se conserva NULL. |
| Vida útil | producto | vida_util | No se obtiene un valor individual de la Tabla III; se conserva NULL. |
| Categoría del producto | producto | id_categoria | Se utiliza la categoría interna «Envases para bebidas», definida por EcoData. |
| País de fabricación | producto | id_pais | No se asigna un país porque el escenario nacional del estudio no confirma el lugar de fabricación de cada envase. |
| Asociación entre producto y material | producto_material | id_producto, id_material | Se vincula cada envase con el material que representa. |
| Huella de carbono | impacto_ambiental | emisiones_co2 | Se almacena en kg CO2 equivalente. |
| Energía total consumida | impacto_ambiental | consumo_energia | Se almacena en megajoules (MJ). |
| Acidificación atmosférica | Sin correspondencia | — | El esquema actual no tiene una columna para este indicador. |
| Eutrofización del agua | Sin correspondencia | — | No existe una columna específica para este indicador. No se confunde con consumo de agua. |
| Consumo de agua | impacto_ambiental | consumo_agua | La Tabla III no proporciona directamente este indicador. Se conserva NULL. |
| Residuos generados | impacto_ambiental | residuos_generados | La Tabla III no proporciona una cantidad de residuos generados. Se conserva NULL. |
| Nivel de impacto | impacto_ambiental | nivel_impacto | La clasificación Bajo, Medio o Alto utilizada en EcoData es una clasificación relativa elaborada por el equipo, no un campo original del artículo. |
| Fecha de medición | impacto_ambiental | fecha_dato | No se proporciona una fecha individual de medición para cada resultado. Se conserva NULL. |
| Autores y título del estudio | fuente | nombre | Se registra la referencia identificable del artículo. |
| Tipo de publicación | fuente | tipo | Se clasifica como artículo científico. |
| DOI o URL | fuente | url | Se conserva el DOI o la dirección de consulta. |
| Fecha de consulta | fuente | fecha_consulta | Se registra la fecha en que el equipo consultó la publicación. |

### Correspondencia de los datos actuales

Los tres productos que ya están registrados en EcoData corresponden a los materiales del estudio:

| Producto | Material asociado | Energía (MJ) | Emisiones (kg CO2e) |
|---|---|---:|---:|
| Botella PET para refresco de 355 ml | PET | 1.8 | 0.095 |
| Envase de vidrio para refresco de 355 ml | Vidrio | 7.6 | 0.813 |
| Lata de aluminio para refresco de 355 ml | Aluminio | 5.1 | 0.301 |

Estos valores coinciden con la Tabla III del artículo.

## 4. Calidad de los datos y decisiones de limpieza

La revisión se realizó sobre la tabla publicada en el artículo PDF. Como no se proporciona un archivo independiente con datos primarios, las observaciones de calidad se limitan a los valores y campos visibles en dicha tabla.

| Problema revisado | Resultado observado | Decisión tomada |
|---|---|---|
| Registros duplicados | No se observan materiales repetidos. | Mantener una observación por material. |
| Campos vacíos | No se observan celdas vacías en los cuatro indicadores de la tabla. | Transcribir los doce valores publicados. |
| Formato numérico | Los valores aparecen con punto decimal y algunos en notación científica. | Convertir la notación científica a decimal sin alterar los valores. |
| Formato de fechas | La tabla no contiene una fecha individual para cada medición. | No generar fechas de medición artificiales. |
| Acentos y caracteres | Los nombres y encabezados se visualizan correctamente en español. | Conservar la escritura original y utilizar UTF-8 en los archivos del proyecto. |
| Valores negativos | No se observan valores negativos en los doce resultados. | Conservar los valores numéricos publicados. |
| Unidades de medida | Cada indicador utiliza una unidad diferente. | Documentar las unidades y evitar mezclar indicadores distintos. |

### Limitaciones de calidad y alcance

El artículo presenta resultados agregados de un Análisis de Ciclo de Vida, no la totalidad de los datos primarios empleados para desarrollar las simulaciones.

Los resultados corresponden al escenario nacional del Caso de estudio I. No deben interpretarse como valores universales para cualquier envase de PET, vidrio o aluminio.

Además, la tabla no contiene información suficiente para completar todos los atributos de EcoData. Por esta razón, se mantienen sin dato los campos que la fuente no proporciona, en lugar de inventar información.

En particular:

- No se infiere el país de fabricación de cada producto a partir del escenario nacional.
- No se asigna un valor de consumo de agua a partir de la eutrofización.
- No se interpreta la eutrofización como cantidad de residuos.
- No se inventan fechas individuales de medición.
- No se atribuye una clasificación de impacto Bajo, Medio o Alto directamente a los autores.

## 5. Conclusión

La fuente seleccionada resulta adecuada para EcoData porque proporciona información publicada y verificable sobre el impacto ambiental de envases cotidianos utilizados en México.

La Tabla III permite comparar tres materiales mediante cuatro indicadores ambientales. Dos de ellos, la huella de carbono y el consumo de energía, ya están representados en el esquema relacional y sus valores coinciden con los tres registros que se encuentran en PostgreSQL.

Los indicadores de acidificación atmosférica y eutrofización del agua no se incorporaron porque el modelo actual no dispone de columnas específicas para almacenarlos. Esta situación se reconoce como una limitación del esquema y como una posible mejora futura.

Se eligió conservar únicamente la información que puede relacionarse de manera justificada con las tablas y columnas actuales, respetando las unidades, el contexto del estudio y la procedencia de los valores.

La fuente no se considera un conjunto de microdatos completo ni una base de datos de cientos de registros; es una tabla de resultados publicada dentro de un artículo científico. Por tanto, los tres registros utilizados son datos extraídos de una publicación real y no datos sintéticos.
## 6. Disponibilidad y alcance del conjunto de datos

La fuente seleccionada se encuentra publicada como artículo científico en formato PDF. Aunque la ficha editorial proporciona acceso al documento, indica que los archivos de datos complementarios todavía no están disponibles para descarga.

Por esta razón, los datos utilizados en EcoData fueron extraídos de la Tabla III del artículo y organizados en una estructura tabular para su incorporación al modelo relacional. No se trata de un archivo independiente CSV o XLSX ni de la totalidad de los datos primarios utilizados por los autores.

El conjunto seleccionado contiene tres materiales y cuatro indicadores ambientales. Por lo tanto, se dispone de tres observaciones comparativas y doce resultados numéricos.

El tamaño exacto del archivo PDF en bytes no está publicado en la ficha editorial, por lo que no se proporciona una cifra que no haya sido medida.

Como alternativa para ampliar el proyecto en el futuro, se identificó Federal LCA Commons, que ofrece inventarios de ciclo de vida descargables en formato JSON-LD y acceso sin necesidad de crear una cuenta. Sin embargo, esos inventarios requieren selección y procesamiento adicionales y no deben mezclarse directamente con los resultados del estudio mexicano sin verificar sus unidades, alcance y metodología.

Sitio: https://www.lcacommons.gov/

Esta limitación se registra para distinguir los resultados publicados de los datos primarios y evitar presentar información que la fuente original no proporciona.