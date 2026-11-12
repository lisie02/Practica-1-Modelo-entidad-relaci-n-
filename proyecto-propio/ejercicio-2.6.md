# Ejercicio 2.6. Comparación de acciones referenciales en EcoData

## Relación seleccionada

Se analizó la relación entre `fuente` e `impacto_ambiental`. La columna `impacto_ambiental.id_fuente` es una llave foránea que identifica la fuente documental de cada registro de impacto ambiental. Se eligió esta relación porque permite evaluar qué sucede con la trazabilidad de los datos cuando se intenta eliminar una fuente.

## Procedimiento

Para evitar modificar la base original, se crearon dos copias de `ecodata`: `ecodata_cascade` y `ecodata_restrict`. En ambas se modificó la llave foránea `impacto_ambiental_id_fuente_fkey`, cambiando su acción `ON DELETE`.

En la primera copia se configuró `ON DELETE CASCADE`. Antes de eliminar la fuente UANL, se encontraron **3 registros** relacionados en `impacto_ambiental`. Después de ejecutar el borrado de la fuente, la consulta de comprobación devolvió **0 registros**. Esto demuestra que `CASCADE` elimina automáticamente los registros dependientes.

En la segunda copia se configuró `ON DELETE RESTRICT`. La consulta inicial también encontró **3 registros** relacionados. Al intentar eliminar la fuente, PostgreSQL rechazó la operación por existir registros que todavía la referencian. La consulta posterior confirmó que los **3 impactos permanecieron**.

## Comparación de resultados

| Acción | Resultado al intentar eliminar la fuente | Impactos después |
|---|---|---:|
| `CASCADE` | Se elimina la fuente y sus registros dependientes | 0 |
| `RESTRICT` | PostgreSQL impide eliminar la fuente | 3 |

## Análisis y decisión

`CASCADE` facilita la eliminación de información relacionada, pero en EcoData puede ocasionar la pérdida de mediciones o registros de impacto ambiental junto con la fuente que documenta su procedencia. Esto afecta la trazabilidad y dificulta comprobar de dónde se obtuvieron los datos.

Por otro lado, `RESTRICT` protege la integridad referencial: impide borrar una fuente mientras existan impactos ambientales asociados. Si una fuente deja de utilizarse, sus registros históricos pueden conservarse y la eliminación puede evitarse hasta que se resuelvan sus dependencias.

Por estas razones, se considera más adecuada la acción **`ON DELETE RESTRICT`** para la relación `fuente` → `impacto_ambiental` en EcoData, ya que prioriza la conservación del historial y la procedencia de la información ambiental.

## Evidencias

- `evidencias/ejercicio-2.6-cascade.png`: resultado de la prueba CASCADE.
- `evidencias/ejercicio-2.6-restrict.png`: rechazo del borrado y conservación de los registros con RESTRICT.

