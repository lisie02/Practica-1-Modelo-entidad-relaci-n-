# Verificación de la base de datos EcoData

## Objetivo

Comprobar la creación de las tablas del modelo relacional y verificar el funcionamiento de las claves primarias, claves foráneas y restricciones de integridad en PostgreSQL mediante Docker.

## Entorno de prueba

- **Proyecto:** EcoData: Impacto ambiental de productos cotidianos.
- **Gestor de bases de datos:** PostgreSQL.
- **Contenedor:** `practica1`.
- **Base de datos:** `ecodata`.

## Pruebas realizadas

### 1. Creación de las tablas

Se ejecutó el archivo `modelo/ecodata.sql` dentro de la base de datos `ecodata`. PostgreSQL respondió con nueve mensajes `CREATE TABLE`, y posteriormente se verificó la existencia de las nueve tablas.

**Resultado:** satisfactorio.

### 2. Verificación de claves foráneas

Se consultaron las restricciones de tipo `FOREIGN KEY` en el esquema `public`. Se identificaron ocho claves foráneas que relacionan los productos con sus categorías y países, los materiales con los productos, los impactos ambientales con los productos y las fuentes, y los subtipos con la entidad principal `producto`.

**Resultado:** satisfactorio.

### 3. Rechazo de referencias inexistentes

Se intentó insertar un producto que referenciaba una categoría y un país inexistentes. PostgreSQL rechazó la operación por una violación de clave foránea.

**Resultado:** satisfactorio. La integridad referencial impidió registrar una referencia inválida.

### 4. Verificación de la clave primaria compuesta

Se comprobó que `producto_material` tiene una clave primaria compuesta por `id_producto` e `id_material`. En una prueba, PostgreSQL rechazó la inserción duplicada de la combinación `(1, 1)`.

**Resultado:** satisfactorio. La restricción impide repetir la misma combinación de producto y material.

### 5. Verificación de la jerarquía ISA

Se revisaron las tablas `producto_reutilizable` y `producto_desechable`. En ambas, `id_producto` está definido como clave primaria y clave foránea hacia `producto`.

**Resultado:** satisfactorio en cuanto a la estructura de las tablas y sus referencias. La exclusividad entre subtipos debe comprobarse o implementarse por separado si se requiere garantizar la disyunción.

## Conclusión

Las pruebas realizadas permiten confirmar que las nueve tablas se crearon correctamente y que las claves foráneas y la clave primaria compuesta funcionan como se esperaba. La estructura de las tablas de la jerarquía ISA también fue verificada. Estas pruebas documentan la implementación inicial del modelo relacional de EcoData en PostgreSQL.
