# Levantamiento del proyecto asignado

## 1. Proyecto

Proyecto asignado: Public Municipal Works.

Repositorio utilizado:

https://github.com/lisie02/PublicMunicipalWorks_DWH.git

El proyecto fue clonado y puesto en funcionamiento localmente mediante Docker Compose.

## 2. Requisitos

Para poner en funcionamiento el proyecto se utilizaron:

- Git
- Docker con Docker Compose
- Sistema operativo Windows

## 3. Clonación del repositorio

Primero se clonó el repositorio del proyecto mediante el siguiente comando:

```bash
git clone https://github.com/lisie02/PublicMunicipalWorks_DWH.git
```

Posteriormente se ingresó a la carpeta del proyecto:

```bash
cd PublicMunicipalWorks_DWH
```

Se verificó el contenido del repositorio mediante:

```bash
dir
```

Entre los elementos encontrados se encuentran las carpetas `backend`, `db`, `docker`, `docs`, `js` y el archivo `README.md`.

## 4. Puesta en funcionamiento del proyecto

Para construir las imágenes y levantar los servicios del proyecto se ejecutó:

```bash
docker compose -f docker/compose.yml up -d --build
```

Este comando permitió construir las imágenes necesarias y poner en funcionamiento los servicios definidos en el archivo de Docker Compose.

## 5. Verificación de los contenedores

Se verificó el estado de los servicios mediante:

```bash
docker compose -f docker/compose.yml ps
```

Se comprobó que los servicios correspondientes a la API y a la base de datos se encontraban funcionando correctamente.

## 6. Generación de datos

Posteriormente se ejecutó el proceso de generación de datos mediante:

```bash
docker compose -f docker/compose.yml --profile tools run --rm seed
```

El proceso terminó exitosamente y generó datos sintéticos para el proyecto.

Entre los datos generados se reportaron:

- 1,247 obras públicas
- 8,934 eventos de auditoría
- 2,341 ciudadanos registrados
- 2,156 propuestas ciudadanas
- 8,723 votos emitidos

Los datos generados son sintéticos y se utilizan con fines académicos y de demostración.

## 7. Consulta a la base de datos

Se verificaron las variables de configuración de PostgreSQL mediante:

```bash
docker compose -f docker/compose.yml exec db env | findstr POSTGRES
```

Se identificó la siguiente información:

- Base de datos: `obras_publicas`
- Usuario: `obras`

Posteriormente se realizaron consultas para verificar las tablas existentes en la base de datos.

Como prueba de funcionamiento de la base de datos se ejecutó:

```sql
SELECT COUNT(*) FROM warehouse.dim_obra;
```

El resultado obtenido fue:

```text
count
-------
1247
(1 row)
```

Esto permitió comprobar que la tabla `warehouse.dim_obra` contiene 1,247 registros.

También se realizó una consulta para visualizar información de las obras:

```sql
SELECT obra_id,
       nombre_obra,
       etapa_nombre,
       estado_nombre,
       fecha_inicio,
       fecha_final
FROM warehouse.dim_obra
ORDER BY obra_id
LIMIT 10;
```

La consulta mostró registros de obras públicas, incluyendo obras como `OBRA-0001`, `OBRA-0002` y `OBRA-0003`.

## 8. Problemática y solución

Un problema que se presentó al levantar el proyecto fue que PostgreSQL sí estaba funcionando, pero la primera consulta falló porque se intentó acceder con el usuario `postgres`, mientras que el proyecto utiliza el usuario `obras`.

Posteriormente, la consulta tampoco encontraba la tabla `dim_obra` porque esta pertenece al esquema `warehouse` y no al esquema `public`.

El problema se resolvió identificando la configuración correcta de la base de datos y utilizando el usuario `obras`. Además, se especificó correctamente el esquema al realizar la consulta:

```sql
SELECT COUNT(*) FROM warehouse.dim_obra;
```

Finalmente, la consulta se ejecutó correctamente y se obtuvieron 1,247 registros, correspondientes a las obras públicas almacenadas en la tabla.

## 9. Evidencias

Las evidencias del levantamiento se encuentran en la carpeta `evidencias/` y muestran:

1. Clonación del repositorio.
2. Contenido del repositorio.
3. Construcción y levantamiento de los contenedores.
4. Verificación del estado de los servicios.
5. Generación de datos.
6. Configuración de la base de datos.
7. Consulta de las tablas.
8. Consulta de prueba a la base de datos y resultado obtenido.
