# Ejercicio 1.6. Usuarios y permisos de EcoData

**Proyecto:** EcoData  
**Gestor:** PostgreSQL  
**Base de datos:** ecodata  
**Fecha:** 5 de noviembre de 2026

## 1. Objetivo

Implementar un esquema de seguridad para EcoData mediante roles y usuarios de PostgreSQL, aplicando el principio de mínimo privilegio.

Se crearon tres roles grupales: aplicación, consulta y administración. Cada uno tiene una función específica y permisos diferentes sobre las nueve tablas del proyecto.

## 2. Roles y usuarios creados

| Rol | Usuario | Función |
|---|---|---|
| rol_ecodata_app | usr_ecodata_app | Permite que la aplicación consulte e inserte información necesaria para la carga de EcoData. |
| rol_ecodata_consulta | usr_ecodata_consulta | Permite consultar las tablas sin modificar sus datos. |
| rol_ecodata_admin | usr_ecodata_admin | Permite administrar los datos, las tablas y las secuencias de la base. |

Los roles grupales se crearon con `NOLOGIN` y los usuarios individuales con `LOGIN INHERIT`.

Cada usuario fue asociado a su rol mediante `GRANT`.

Las contraseñas se configuraron interactivamente con el comando `\password` de PostgreSQL. No se almacenaron en archivos SQL, Markdown ni en el repositorio.

## 3. Permisos asignados

### 3.1. Rol de aplicación

El usuario `usr_ecodata_app` necesita consultar e insertar datos para ejecutar el programa de carga automatizada.

Se le otorgaron permisos `SELECT` e `INSERT` en:

- categoria
- fuente
- material
- producto
- producto_material
- impacto_ambiental

También recibió permisos `USAGE` y `SELECT` sobre las secuencias, además de permiso temporal para crear tablas temporales durante el proceso de carga.

No tiene permisos de eliminación ni actualización de registros.

No tiene acceso de lectura o escritura a las tablas de especialización `producto_reutilizable` y `producto_desechable`.

### 3.2. Rol de consulta

El usuario `usr_ecodata_consulta` recibió únicamente permisos `SELECT` sobre las nueve tablas del esquema `public`.

Puede consultar la información, pero no puede insertar, actualizar ni eliminar registros.

### 3.3. Rol de administración

El usuario `usr_ecodata_admin` recibió todos los privilegios sobre las nueve tablas y las secuencias existentes, además del permiso `CREATE` en el esquema `public`.

Este usuario puede administrar los datos y crear objetos dentro del esquema.

No es superusuario y no tiene el atributo `CREATEROLE`; por ello, no puede crear nuevos roles de PostgreSQL.

## 4. Conexión del programa de carga

El programa `poblar.ps1` se ejecutó utilizando el usuario de aplicación.

Las variables configuradas en PowerShell fueron:

```powershell
$env:PGUSER = "usr_ecodata_app"
$env:PGDATABASE = "ecodata"
```

La ejecución del programa terminó correctamente con `COMMIT`.

El resumen de la segunda carga fue:

| Tabla | Insertados | Omitidos | Rechazados |
|---|---:|---:|---:|
| categoria | 0 | 1 | 0 |
| fuente | 0 | 1 | 0 |
| material | 0 | 3 | 0 |
| producto | 0 | 3 | 0 |
| producto_material | 0 | 3 | 0 |
| impacto_ambiental | 0 | 3 | 0 |

Los registros ya existentes fueron reconocidos y no se duplicaron.

## 5. Pruebas de permisos

### Prueba 1. Usuario de aplicación

**Usuario:** `usr_ecodata_app`

Operación permitida:

```sql
SELECT COUNT(*) FROM producto;
```

Resultado observado:

```text
count
-----
3
```

Operación denegada:

```sql
DELETE FROM producto
WHERE id_producto = -999;
```

Mensaje observado:

```text
ERROR: permission denied for table producto
```

**Conclusión:** el usuario puede consultar productos, pero no eliminarlos.

### Prueba 2. Usuario de consulta

**Usuario:** `usr_ecodata_consulta`

Operación permitida:

```sql
SELECT COUNT(*) FROM impacto_ambiental;
```

Resultado observado:

```text
count
-----
3
```

Operación denegada:

```sql
INSERT INTO categoria (nombre, descripcion)
VALUES ('Categoria de prueba', 'Prueba de permisos');
```

Mensaje observado:

```text
ERROR: permission denied for table categoria
```

**Conclusión:** el usuario puede consultar los registros, pero no insertar información.

### Prueba 3. Usuario administrador

**Usuario:** `usr_ecodata_admin`

Operación permitida:

```sql
BEGIN;

INSERT INTO categoria (nombre, descripcion)
VALUES (
    'Categoria temporal admin',
    'Prueba de permisos administrativos'
);

SELECT *
FROM categoria
WHERE nombre = 'Categoria temporal admin';

ROLLBACK;
```

Resultado observado:

```text
INSERT 0 1

ROLLBACK
```

La consulta mostró el registro temporal antes de revertirlo.

Operación denegada:

```sql
CREATE ROLE usuario_no_autorizado;
```

Mensaje observado:

```text
ERROR: permission denied to create role
DETAIL: Only roles with the CREATEROLE attribute may create roles.
```

**Conclusión:** el usuario administrador puede insertar y consultar datos, pero no puede crear roles porque no es superusuario ni tiene el atributo `CREATEROLE`.

## 6. Prueba de REVOKE y restauración

Para comprobar que los permisos pueden retirarse, se eliminó temporalmente el permiso de lectura de productos al rol de aplicación.

Operación:

```sql
REVOKE SELECT ON TABLE producto
FROM rol_ecodata_app;
```

Resultado:

```text
REVOKE
```

Después se inició sesión con `usr_ecodata_app` y se intentó consultar:

```sql
SELECT COUNT(*) FROM producto;
```

Mensaje observado:

```text
ERROR: permission denied for table producto
```

La operación fue denegada, demostrando que el permiso había sido retirado.

Finalmente, se restauró el permiso:

```sql
GRANT SELECT ON TABLE producto
TO rol_ecodata_app;
```

Resultado:

```text
GRANT
```

De esta manera, el usuario de aplicación recuperó el permiso necesario para ejecutar el programa de carga.

## 7. Matriz de permisos

La siguiente matriz representa los privilegios asignados a cada rol sobre las nueve tablas del esquema `public`.

| Tabla | Aplicación | Consulta | Administración |
|---|---|---|---|
| categoria | SELECT, INSERT | SELECT | ALL |
| pais | Sin acceso | SELECT | ALL |
| material | SELECT, INSERT | SELECT | ALL |
| fuente | SELECT, INSERT | SELECT | ALL |
| producto | SELECT, INSERT | SELECT | ALL |
| producto_reutilizable | Sin acceso | SELECT | ALL |
| producto_desechable | Sin acceso | SELECT | ALL |
| producto_material | SELECT, INSERT | SELECT | ALL |
| impacto_ambiental | SELECT, INSERT | SELECT | ALL |

### Permisos adicionales

| Recurso | Aplicación | Consulta | Administración |
|---|---|---|---|
| Esquema public | USAGE | USAGE | USAGE, CREATE |
| Base ecodata | CONNECT, TEMPORARY | CONNECT | CONNECT |
| Secuencias existentes | USAGE, SELECT | Sin permisos explícitos | ALL |

## 8. Conclusión

La implementación de roles y usuarios permitió separar las actividades de aplicación, consulta y administración de EcoData.

Las pruebas demostraron que cada usuario puede realizar sus operaciones autorizadas y que PostgreSQL rechaza las acciones que no corresponden a sus privilegios.

También se comprobó la utilidad de `REVOKE`, ya que al retirar temporalmente el permiso de lectura el usuario de aplicación dejó de consultar productos. Posteriormente se restauró el acceso con `GRANT`.

Finalmente, el programa de carga automatizada se ejecutó correctamente con el usuario de aplicación y conservó los registros existentes sin duplicarlos.

La separación de permisos reduce el riesgo de modificaciones accidentales y evita que todas las operaciones de la base de datos dependan de una cuenta administradora.
