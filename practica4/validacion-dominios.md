# Validación de restricciones de dominio de EcoData

**Práctica:** 4
**Ejercicio:** 1.2 - Restricciones de dominio
**Gestor de base de datos:** PostgreSQL
**Base de datos:** ecodata

## 1. Implementación

Se ejecutó el archivo `001-dominios.sql`, que agregó 13 restricciones CHECK al esquema de EcoData.

Las restricciones validan:
- Que los nombres de categorías, países, materiales, fuentes y productos no estén vacíos.
- Que los precios no sean negativos.
- Que los indicadores ambientales no sean negativos.
- Que el nivel de impacto utilice una etiqueta reconocida.
- Que las cantidades de reutilizaciones y tiempos de descomposición no sean negativas.

## 2. Pruebas realizadas

### Prueba 1. Nombre vacío

Se intentó insertar una categoría con el nombre vacío.

**Resultado:** PostgreSQL rechazó la operación mediante la restricción `chk_categoria_nombre_no_vacio`.

**Estado:** Correcta.

### Prueba 2. Emisiones negativas

Se intentó actualizar un registro de impacto ambiental asignando -1 a `emisiones_co2`.

**Resultado:** PostgreSQL rechazó la operación mediante la restricción `chk_impacto_co2_no_negativo`.

**Estado:** Correcta.

## 3. Verificación de los datos

Después de las pruebas se consultó la tabla `impacto_ambiental`.

Se conservaron los tres registros originales:

| ID impacto | ID producto | Consumo de energía | Emisiones CO2 |
|---:|---:|---:|---:|
| 1 | 4 | 1.80 | 0.095000 |
| 2 | 5 | 7.60 | 0.813000 |
| 3 | 6 | 5.10 | 0.301000 |

No se agregaron categorías de prueba ni se modificaron permanentemente los indicadores ambientales.

## 4. Conclusión

La implementación de las restricciones de dominio permitió fortalecer la integridad de EcoData. Las pruebas demostraron que PostgreSQL impide registrar nombres vacíos y valores negativos en los indicadores ambientales. Finalmente, se verificó que los datos originales permanecieron sin cambios.
