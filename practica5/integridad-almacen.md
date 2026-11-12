# Ejercicio 2.5. Integridad referencial en el almacen asignado

**Proyecto:** PublicMunicipalWorks_DWH  
**Base de datos:** obras_publicas  
**Gestor:** PostgreSQL  
**Esquema:** warehouse  
**Fecha:** 6 de noviembre de 2026

## 1. Objetivo

Identificar las tablas de hechos y dimensiones, determinar la granularidad de las tablas principales y comprobar la integridad referencial del almacen de obras publicas.

## 2. Tablas de hechos y granularidad

Se identificaron dos tablas principales de hechos.

### 2.1 fact_eventos_auditoria

Registra eventos individuales relacionados con las obras publicas.

- Granularidad: un registro por evento de auditoria.
- Clave primaria compuesta: `(tiempo_key, evento_key)`.
- Particionamiento: RANGE por `tiempo_key`.
- Particiones identificadas: 2024, 2025 y 2026.

Se relaciona con diez dimensiones:

1. dim_tiempo
2. dim_tipo_evento
3. dim_obra
4. dim_region
5. dim_personal
6. dim_constructora
7. dim_fuente
8. dim_presupuesto
9. dim_poblador
10. dim_propuesta

### 2.2 fact_obra_mensual

Almacena indicadores de seguimiento de las obras por periodo.

- Granularidad: una fila por obra y mes.
- Clave primaria compuesta: `(tiempo_key, obra_key)`.
- Claves foraneas: `obra_key` y `tiempo_key`.
- Registros previamente consultados: 29,928.

Sus medidas incluyen presupuesto, costos, saldo, porcentaje ejercido, avance fisico, avance presupuestario, retrasos, informes, imagenes y permisos.

## 3. Dimensiones identificadas

| Dimension | Funcion |
|---|---|
| dim_tiempo | Informacion de fechas y calendario. |
| dim_tipo_evento | Clasificacion de los eventos. |
| dim_obra | Datos descriptivos de las obras. |
| dim_region | Ubicacion territorial. |
| dim_constructora | Informacion de constructoras. |
| dim_personal | Personal relacionado con las obras. |
| dim_fuente | Procedencia de la informacion. |
| dim_presupuesto | Datos presupuestarios. |
| dim_poblador | Informacion de participantes ciudadanos. |
| dim_propuesta | Propuestas ciudadanas. |

Tambien se identifico la tabla `modelo_ia`, relacionada con la tabla `prediccion_riesgo`.

## 4. Inventario de claves foraneas

La consulta al catalogo `pg_constraint` identifico:

| Tabla | Claves foraneas |
|---|---:|
| fact_eventos_auditoria | 10 |
| fact_obra_mensual | 2 |
| prediccion_riesgo | 2 |
| **Total** | **14** |

Las diez claves de `fact_eventos_auditoria` conectan sus registros con las dimensiones correspondientes. Las dos claves de `fact_obra_mensual` conectan cada snapshot con una obra y un periodo.

En `prediccion_riesgo` se identificaron dos relaciones compuestas:

- `(tiempo_key, obra_key)` referencia la clave de `fact_obra_mensual`.
- `(id_modelo, version_modelo)` referencia la version correspondiente de `modelo_ia`.

Las particiones de la tabla de auditoria tambien muestran estas relaciones, pero no deben contarse como diez relaciones logicas diferentes por cada particion.

## 5. Comprobacion de referencias huerfanas

Se realizaron doce comprobaciones entre las dos tablas de hechos y sus dimensiones mediante consultas con `LEFT JOIN`.

| Relacion | Registros huerfanos |
|---|---:|
| Eventos -> Region | 0 |
| Eventos -> Tiempo | 0 |
| Eventos -> Tipo evento | 0 |
| Eventos -> Obra | 0 |
| Eventos -> Personal | 0 |
| Eventos -> Constructora | 0 |
| Eventos -> Fuente | 0 |
| Eventos -> Presupuesto | 0 |
| Eventos -> Poblador | 0 |
| Eventos -> Propuesta | 0 |
| Hechos mensuales -> Obra | 0 |
| Hechos mensuales -> Tiempo | 0 |
| **Total de relaciones revisadas** | **12** |

**Resultado:** no se encontraron claves foraneas huerfanas.

Las columnas opcionales que contienen NULL no se consideraron referencias huerfanas, ya que no representan una referencia a una dimension inexistente.

## 6. Verificacion de claves primarias compuestas

Se revisaron las combinaciones que identifican los registros de las dos tablas de hechos.

| Tabla | Clave primaria | Grupos duplicados |
|---|---|---:|
| fact_eventos_auditoria | tiempo_key, evento_key | 0 |
| fact_obra_mensual | tiempo_key, obra_key | 0 |

No se encontraron grupos duplicados.

## 7. Consideraciones sobre las claves foraneas

Algunos almacenes de datos pueden omitir restricciones fisicas durante las cargas masivas para reducir el costo de las operaciones ETL. Sin embargo, esa decision requiere controles alternativos para impedir que los hechos apunten a dimensiones inexistentes.

En este proyecto las claves foraneas ya estan declaradas. Por lo tanto, no fue necesario agregar restricciones redundantes ni modificar la base original.

## 8. Archivo de verificacion

Se preparo el archivo:

`sql/007-verificacion-almacen.sql`

Contiene consultas para:
- Consultar las claves foraneas declaradas.
- Buscar referencias huerfanas.
- Comprobar las claves primarias compuestas.
- Contabilizar las claves foraneas de las tablas principales.

Las consultas son de solo lectura.

## 9. Conclusion

El analisis permitio identificar la granularidad de las dos tablas de hechos y las dimensiones con las que se relacionan. La tabla de auditoria registra eventos individuales, mientras que la tabla mensual representa una combinacion de obra y periodo.

Las doce comprobaciones realizadas entre hechos y dimensiones devolvieron cero registros huerfanos. Asimismo, las claves primarias compuestas no presentaron grupos duplicados.

Se concluye que las relaciones principales del almacen ya estan implementadas y que los registros revisados conservan su integridad referencial. No fue necesario agregar claves foraneas redundantes ni modificar la base de datos original.
