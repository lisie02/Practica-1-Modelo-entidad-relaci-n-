# Ejercicio 1.3. Normalización de una tabla hasta 3FN

**Proyecto:** EcoData  
**Gestor de base de datos:** PostgreSQL  
**Base de datos de pruebas:** `ecodata_pruebas`  
**Entorno:** Docker y Visual Studio Code

## 1. Objetivo

Aplicar el proceso de normalización a una tabla desnormalizada del proyecto EcoData, identificando las dependencias funcionales y separando la información hasta alcanzar la tercera forma normal (3FN).

Se busca reducir la redundancia de información, evitar anomalías de inserción, actualización y eliminación, y garantizar la integridad de los datos mediante claves primarias y foráneas.

## 2. Creación de la tabla desnormalizada

Se creó la tabla `practica_13_desnormalizada`, que concentra información procedente de las tablas originales de EcoData.

Los atributos utilizados fueron:

- id_reporte
- id_producto
- nombre_producto
- marca
- id_categoria
- nombre_categoria
- id_fuente
- nombre_fuente
- emisiones_co2
- consumo_energia
- nivel_impacto

Se recuperaron tres registros mediante consultas JOIN entre las tablas `impacto_ambiental`, `producto`, `categoria` y `fuente`.

Los productos registrados fueron:

1. Botella PET para refresco de 355 ml.
2. Envase de vidrio para refresco de 355 ml.
3. Lata de aluminio para refresco de 355 ml.

## 3. Identificación de dependencias funcionales

A partir de la estructura de la tabla se identificaron las siguientes dependencias funcionales:

- id_reporte → id_producto, id_fuente, emisiones_co2, consumo_energia, nivel_impacto.
- id_producto → nombre_producto, marca, id_categoria.
- id_categoria → nombre_categoria.
- id_fuente → nombre_fuente.

Estas dependencias permiten identificar qué atributos dependen de cada identificador y justifican la separación de la información en diferentes tablas.

## 4. Aplicación de las formas normales

### 4.1 Primera Forma Normal (1FN)

La tabla cumple la primera forma normal porque sus atributos contienen valores individuales y no existen grupos repetitivos dentro de una misma columna.

Cada registro representa un reporte ambiental y cada campo almacena un solo valor.

**Resultado:** se cuenta con una estructura de atributos atómicos.

### 4.2 Segunda Forma Normal (2FN)

La tabla utiliza `id_reporte` como clave primaria simple.

Por lo tanto, no existen dependencias parciales respecto de una clave compuesta. Al cumplirse la primera forma normal, también se satisface la condición de segunda forma normal.

**Resultado:** no se identificaron dependencias parciales.

### 4.3 Tercera Forma Normal (3FN)

Para eliminar las dependencias transitivas identificadas, se separó la información en cuatro tablas relacionadas.

**Tabla CATEGORIA_3FN**

- id_categoria (PK)
- nombre_categoria

**Tabla PRODUCTO_3FN**

- id_producto (PK)
- nombre_producto
- marca
- id_categoria (FK)

**Tabla FUENTE_3FN**

- id_fuente (PK)
- nombre_fuente

**Tabla REPORTE_3FN**

- id_reporte (PK)
- id_producto (FK)
- id_fuente (FK)
- emisiones_co2
- consumo_energia
- nivel_impacto

Esta estructura permite que los datos descriptivos de las categorías y fuentes se almacenen una sola vez y que los reportes se relacionen con los productos correspondientes.

## 5. Relaciones entre las tablas

Se establecieron las siguientes relaciones:

- CATEGORIA_3FN (1:N) PRODUCTO_3FN.
- PRODUCTO_3FN (1:N) REPORTE_3FN.
- FUENTE_3FN (1:N) REPORTE_3FN.

Las relaciones se implementaron mediante claves foráneas para mantener la integridad referencial.

## 6. Resultados de ejecución

El archivo `013-normalizacion-3fn.sql` se ejecutó correctamente en PostgreSQL, utilizando la base de datos `ecodata_pruebas`.

Los resultados fueron:

| Tabla | Registros insertados |
|---|---:|
| categoria_3fn | 1 |
| producto_3fn | 3 |
| fuente_3fn | 1 |
| reporte_3fn | 3 |
| **Total** | **8** |

Se crearon cuatro tablas y se insertaron ocho registros distribuidos entre ellas.

## 7. Verificación de claves primarias y foráneas

Se consultó el catálogo `information_schema` para comprobar las restricciones de las cuatro tablas.

Se identificaron siete restricciones:

- Cuatro claves primarias.
- Tres claves foráneas.

Las relaciones verificadas fueron:

- producto_3fn.id_categoria referencia categoria_3fn.id_categoria.
- reporte_3fn.id_producto referencia producto_3fn.id_producto.
- reporte_3fn.id_fuente referencia fuente_3fn.id_fuente.

## 8. Verificación de integridad referencial

Se ejecutaron consultas para identificar registros que no tuvieran una categoría, producto o fuente relacionada.

Los resultados fueron:

| Verificación | Errores |
