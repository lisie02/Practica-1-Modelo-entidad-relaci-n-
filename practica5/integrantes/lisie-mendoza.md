# Ejercicio 2.6. Trabajo individual: cambio de acción referencial

**Nombre:** Lisie Mendoza  
**Usuario de GitHub:** lisie02  
**Proyecto:** EcoData  
**Gestor:** PostgreSQL  
**Base individual de pruebas:** `ecodata_individual_lisie`  
**Fecha:** 12 de noviembre de 2026

## 1. Relación seleccionada

Para este ejercicio seleccioné la relación entre las tablas `producto` e `impacto_ambiental`.

- Tabla padre: `producto`.
- Clave primaria: `producto.id_producto`.
- Tabla hija: `impacto_ambiental`.
- Clave foránea: `impacto_ambiental.id_producto`.

Esta relación representa que un producto puede tener varios registros de impacto ambiental y que cada medición debe corresponder a un producto existente.

La acción referencial original era:

```sql
ON DELETE RESTRICT
ON UPDATE CASCADE
```

## 2. Regla de transformación aplicada

En una copia individual de EcoData cambié la acción `ON DELETE RESTRICT` por `ON DELETE CASCADE`, conservando `ON UPDATE CASCADE`.

La migración se realizó mediante:

```sql
ALTER TABLE public.impacto_ambiental
DROP CONSTRAINT impacto_ambiental_id_producto_fkey;

ALTER TABLE public.impacto_ambiental
ADD CONSTRAINT impacto_ambiental_id_producto_fkey
FOREIGN KEY (id_producto)
REFERENCES public.producto(id_producto)
ON DELETE CASCADE
ON UPDATE CASCADE;
```

El cambio se aplicó únicamente en `ecodata_individual_lisie`. La base original `ecodata` y la copia general `ecodata_pruebas` no fueron modificadas.

## 3. Comparación con datos

Se utilizó el producto con identificador 4:

**Botella PET para refresco de 355 ml.**

Antes de realizar el cambio experimental, se probó la acción original `RESTRICT`. PostgreSQL rechazó el intento de eliminar el producto porque existía un registro de impacto ambiental relacionado.

El mensaje observado fue:

```text
PRUEBA CORRECTA: RESTRICT rechazo el borrado.
Impactos antes: 1, despues: 1.
```

Después se aplicó `CASCADE` y se volvió a intentar eliminar el mismo producto dentro de una transacción.

### 3.1 Resultado antes de eliminar

| Tabla o registro | Cantidad |
|---|---:|
| Producto 4 | 1 |
| Impactos del producto 4 | 1 |
| Asociaciones producto-material | 1 |
| Material PET | 1 |
| Fuente UANL | 1 |
| Otros productos 5 y 6 | 2 |

### 3.2 Resultado después de CASCADE

| Tabla o registro | Cantidad |
|---|---:|
| Producto 4 | 0 |
| Impactos del producto 4 | 0 |
| Asociaciones del producto 4 | 0 |
| Material PET | 1 |
| Fuente UANL | 1 |
| Otros productos 5 y 6 | 2 |

La operación eliminó el producto, su registro de impacto ambiental y su asociación con el material PET. Sin embargo, conservó el material, la fuente documental y los otros productos.

### 3.3 Comprobación de la reversión

La demostración terminó con `ROLLBACK`. Después de la reversión se obtuvieron nuevamente los siguientes conteos:

| Tabla | Registros restaurados |
|---|---:|
| producto | 3 |
| impacto_ambiental | 3 |
| producto_material | 3 |

Esto confirmó que la prueba no dejó modificaciones permanentes en la copia individual.

## 4. ¿Qué se pierde y qué se conserva?

Con `RESTRICT`, el producto no se puede eliminar mientras tenga mediciones ambientales relacionadas. Se conserva tanto el producto como su historial.

Con `CASCADE`, se permite eliminar el producto, pero también desaparecen sus mediciones y las asociaciones que dependen de él. Los materiales y las fuentes se conservan porque son registros independientes y pueden estar relacionados con otros productos o impactos.

La diferencia es importante porque EcoData utiliza las mediciones ambientales para comparar materiales y productos. Si se eliminan los registros de impacto, se puede perder información útil para consultas históricas y comparaciones posteriores.

## 5. ¿Cuál acción es correcta para EcoData?

Considero que `ON DELETE RESTRICT` es la opción más adecuada para esta relación.

La razón es que los impactos ambientales representan información histórica y documental del producto. Eliminar un producto no debería provocar automáticamente la pérdida de mediciones que pueden utilizarse como evidencia o referencia para análisis posteriores.

Aunque `CASCADE` puede ser útil en relaciones donde el registro hijo no tiene sentido sin el padre, en este caso debe darse prioridad a la conservación del historial ambiental.

Para retirar un producto del catálogo sería preferible utilizar un mecanismo de baja lógica o un estado de disponibilidad, conservando sus mediciones y relaciones históricas.

Por lo tanto, el cambio a `CASCADE` se realizó únicamente con fines experimentales y no se recomienda aplicarlo a la base original de EcoData.

## 6. Conclusión

La prueba permitió observar con datos reales la diferencia entre `RESTRICT` y `CASCADE`. Con `RESTRICT`, PostgreSQL protegió el producto y su medición ambiental. Con `CASCADE`, se eliminaron ambos registros y también la relación con el material, pero se conservaron el material PET, la fuente UANL y los otros productos.

Esta comparación demuestra que una acción referencial debe elegirse de acuerdo con las reglas del dominio y no solamente por conveniencia técnica.

Para EcoData considero que `RESTRICT` protege mejor la trazabilidad y el historial de los impactos ambientales.

---

**Responsable del ejercicio:**  
Lisie Mendoza  
**Usuario de GitHub:** lisie02

**Firma:** Lisie Mendoza
