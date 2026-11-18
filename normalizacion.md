# Normalización de EcoData

**Proyecto propio:** EcoData, una base de datos para medir el impacto ambiental de productos cotidianos.
**Gestor:** PostgreSQL. **Rama:** `practica6-8`.

---

## Ejercicio 1.2. Las dependencias funcionales

### Esquema analizado

Se toma el esquema poblado con el que terminaron las Prácticas 4 y 5: `modelo/ecodata.sql`, las migraciones `practica4/001-dominios.sql`, `practica4/002-reglas-pruebas.sql` y `practica5/sql/001-acciones-referenciales.sql`, y las tablas de usuarios de `sql/010-usuarios-ecodata.sql`. Son once tablas.

La columna `producto.activo` de `practica5/sql/004-borrado-logico.sql` se aplicó solo en `ecodata_pruebas`, así que no forma parte de la base principal. Si se incorpora, se agrega `id_producto → activo` y no cambia ninguna clave.

### Notación

Dentro de cada tabla, los atributos se abrevian con una letra, y la leyenda acompaña a cada tabla. `X⁺` es el cierre de `X` bajo el conjunto de dependencias indicado. Todo el análisis se puede repetir con:

```bash
python3 practica6-8/dependencias/dependencias.py practica6-8/dependencias/F-ecodata.txt
```

El conjunto F está en `dependencias/F-ecodata.txt` y la salida completa del programa en `evidencias/dependencias-salida.txt`. Los cierres de este documento coinciden con esa salida.

---

### 1. El conjunto F y las reglas que lo justifican

Cada dependencia sale de una regla del negocio. La columna «Dónde consta» indica dónde el equipo ya había tomado esa decisión: una restricción en una migración, la forma en que los scripts de carga detectan duplicados o el diccionario de datos.

#### `categoria` (G = id_categoria, N = nombre, D = descripcion)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| G → N D | RN1. Cada categoría tiene un solo nombre y una sola descripción. | PK `id_categoria` |
| N → G | RN2. No hay dos categorías con el mismo nombre. El nombre es lo que el usuario ve para elegir una categoría. | `poblar.sql` y `productos_mexico.sql` identifican la categoría por `nombre`. **Aún no hay `UNIQUE`.** |

#### `pais` (T = id_pais, N = nombre)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| T → N | RN3. Cada país tiene un solo nombre en el catálogo. | PK `id_pais` |
| N → T | RN4. Un país no se registra dos veces. | Regla de catálogo. **Aún no hay `UNIQUE`.** |

#### `material` (M = id_material, N = nombre, D = descripcion, Y = tipo, R = reciclable)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| M → N D Y R | RN5. Cada material tiene un nombre, una descripción, una familia (`tipo`) y una clasificación de reciclable. | PK `id_material` |
| N → M | RN6. El nombre del material es único. | `uq_material_nombre` (Práctica 4) |
| N → Y | RN7. Cada material pertenece a una sola familia: el PET es plástico y el aluminio es metal. | Diccionario de datos |

#### `fuente` (S = id_fuente, N = nombre, Y = tipo, U = url, C = fecha_consulta)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| S → N Y U C | RN8. Cada fuente registrada tiene un título, un tipo de documento, una dirección y una fecha de consulta. | PK `id_fuente` |
| U → S | RN9. Una URL o un DOI se registra una sola vez. | `uq_fuente_url` (Práctica 4). `poblar.sql` detecta la fuente repetida por `url`. |
| U → N Y | RN10. Un DOI identifica un documento con un solo título y un solo tipo. | Definición de DOI |

#### `producto` (P = id_producto, N = nombre, M = marca, Q = precio_aproximado, V = vida_util, G = id_categoria, T = id_pais)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| P → N M Q V G T | RN11. Cada producto tiene un nombre, una marca, un precio de referencia, una vida útil, una categoría y a lo sumo un país de fabricación. | PK `id_producto`; FK a `categoria` y `pais` |
| N G → P | RN12. No hay dos productos con el mismo nombre dentro de la misma categoría. | `uq_producto_nombre_categoria` (Práctica 4) |

#### `producto_reutilizable` (P = id_producto, K = numero_reutilizaciones, Z = requiere_mantenimiento)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| P → K Z | RN13. Un producto reutilizable tiene un número de reutilizaciones y requiere o no mantenimiento. | PK/FK `id_producto` |

#### `producto_desechable` (P = id_producto, A = tiempo_descomposicion_anios, R = genera_residuos)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| P → A R | RN14. Un producto desechable tiene un tiempo de descomposición y genera o no residuos. | PK/FK `id_producto` |

#### `producto_material` (P = id_producto, M = id_material)

RN15: un producto puede estar hecho de varios materiales, y un material puede usarse en varios productos. Por eso no se cumplen ni `P → M` ni `M → P`. **Esta tabla solo tiene dependencias triviales.**

#### `impacto_ambiental` (I = id_impacto, P = id_producto, S = id_fuente, A = consumo_agua, E = consumo_energia, C = emisiones_co2, R = residuos_generados, N = nivel_impacto, D = fecha_dato)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| I → P S A E C R N D | RN16. Cada registro de impacto es de un producto, según una fuente, y tiene un valor por indicador. | PK `id_impacto` |
| P S → I | RN17. Una fuente aporta a lo sumo un registro de impacto por producto. Si un estudio publica una edición nueva, esa edición tiene otro DOI y es otra fuente (RN9). | `productos_mexico.sql` detecta el registro repetido por `(id_producto, id_fuente)`. **Aún no hay `UNIQUE`.** |
| P S D → A E C R N | RN18. Para un producto y la fecha del dato, una fuente reporta un único valor por indicador y una única clasificación. | Forma en que el equipo describió el registro de impacto |

#### `usuario_ecodata` (U = id_usuario, N = nombre, C = correo, H = password_hash, F = fecha_registro, A = activo)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| U → N C H F A | RN19. Cada usuario tiene un nombre, un correo, una contraseña cifrada, una fecha de registro y un estado. | PK `id_usuario` |
| C → U | RN20. Un correo pertenece a una sola cuenta, sin distinguir mayúsculas. | Índice único `uq_usuario_ecodata_correo` sobre `LOWER(correo)` |

#### `usuario_sesion_ecodata` (S = id_sesion, U = id_usuario, K = token_hash, C = creada_en, X = expira_en)

| DF | Regla del negocio | Dónde consta |
|---|---|---|
| S → U K C X | RN21. Cada sesión es de un usuario y tiene un token, una fecha de creación y una de expiración. | PK `id_sesion` |
| K → S | RN22. Cada token identifica una sola sesión. | `token_hash UNIQUE` |

#### Dependencias que se descartaron

Varias dependencias **se cumplen en las filas de ejemplo**, pero las reglas del negocio no las sostienen. Por eso no entran en F. La base actual tiene solo tres productos, todos de la misma marca, con un único estudio como fuente, así que es muy fácil confundir una coincidencia con una dependencia.

| DF descartada | ¿Se cumple en los datos de ejemplo? | Por qué no es una regla |
|---|---|---|
| `impacto_ambiental`: P → S | Sí: los tres registros vienen de la fuente UANL, así que `id_producto` parece una clave. | Un producto puede tener registros de varias fuentes. Esa es la razón de ser de EcoData. |
| `impacto_ambiental`: C → N (emisiones → nivel) | Sí: cada valor de emisiones tiene un nivel distinto. | El nivel es una clasificación **relativa** entre los envases de un mismo caso de estudio. Las mismas emisiones pueden ser «Bajo» en un estudio y «Medio» en otro. |
| `producto`: N → P (nombre → producto) | Sí: los tres nombres son distintos. | La regla del equipo es que el nombre es único **dentro de la categoría** (RN12), no en toda la tabla. |
| `producto`: M → G (marca → categoría) | Sí: Coca-Cola aparece solo en «Envases para bebidas». | Una marca vende productos de varias categorías. |
| `producto`: M → T (marca → país) | Sí, de forma trivial: el país es NULL en todas las filas. | Una marca fabrica en varios países. |
| `material`: Y → R (tipo → reciclable) | Sí: los cuatro materiales son reciclables. | Dentro de la familia «Plástico» hay materiales reciclables, como el PET, y otros que en la práctica no lo son, como el poliestireno. |
| `fuente`: N → S (título → fuente) | Sí: los tres títulos son distintos. | Dos documentos pueden tener el mismo título, por ejemplo dos ediciones de un informe. El identificador es la URL o el DOI (RN9). |
| `usuario_sesion_ecodata`: C → X (creada → expira) | — | La duración depende de `SESSION_DAYS` (de 1 a 30 días, configurable en `.env`). Además, `server.js` calcula `expira_en` y la base calcula `creada_en`, así que no hay una función fija entre ambas. |
| `usuario_sesion_ecodata`: U → K (usuario → token) | — | `createSession` inserta una sesión nueva en cada inicio de sesión, así que un usuario puede tener varias sesiones abiertas. |

#### Decisiones que el equipo debe confirmar

- **RN2, RN4 y RN17** son reglas que el equipo ya aplica en sus scripts de carga, pero que todavía no son restricciones en la base. Si el equipo las confirma, en el 1.3 se declaran como `UNIQUE`.
- **RN17** precisa lo que el inventario EER dice de forma general: «un producto puede tener varios registros de impacto a lo largo del tiempo». Con esta regla, la historia de un producto se forma con fuentes distintas. Si el equipo quiere que una misma fuente reporte un producto en varias fechas, la regla sería `P S D → I`, la clave sería `{P, S, D}` y `fecha_dato` tendría que ser NOT NULL. Cambiaría el resultado de las secciones 2 y 3 para esta tabla.

---

### 2. Cierres de atributos y claves candidatas

**Método.** En cada tabla, los atributos se clasifican según el lado en que aparecen dentro de F:

- Un atributo que **solo aparece a la izquierda** o que **no aparece en ninguna dependencia** está en toda clave; esos atributos forman el *núcleo*.
- Un atributo que **solo aparece a la derecha** no está en ninguna clave.
- Con los atributos que aparecen en **ambos lados** se prueban combinaciones de menor a mayor tamaño, agregándolas al núcleo. Un conjunto es clave candidata si su cierre contiene todos los atributos y ninguno de sus subconjuntos lo logra. Los superconjuntos de una clave ya encontrada no se prueban.

#### `categoria` (G, N, D)

Solo a la derecha: D. En ambos lados: G, N. Núcleo: ∅.

```
{G}⁺ = {G}  →  por G → N D: {G, N, D}                              ✔ clave
{N}⁺ = {N}  →  por N → G: {N, G}  →  por G → N D: {N, G, D}          ✔ clave
```

Claves candidatas: **{G}** y **{N}**.

#### `pais` (T, N)

```
{T}⁺ = {T}  →  por T → N: {T, N}   ✔ clave
{N}⁺ = {N}  →  por N → T: {N, T}   ✔ clave
```

Claves candidatas: **{T}** y **{N}**.

#### `material` (M, N, D, Y, R)

Solo a la derecha: D, Y, R. En ambos lados: M, N. Núcleo: ∅.

```
{M}⁺ = {M}  →  por M → N D Y R: {M, N, D, Y, R}                          ✔ clave
{N}⁺ = {N}  →  por N → M: {N, M}  →  por N → Y: {N, M, Y}
            →  por M → N D Y R: {M, N, D, Y, R}                          ✔ clave
```

Claves candidatas: **{M}** y **{N}**.

#### `fuente` (S, N, Y, U, C)

Solo a la derecha: N, Y, C. En ambos lados: S, U. Núcleo: ∅.

```
{S}⁺ = {S}  →  por S → N Y U C: {S, N, Y, U, C}                          ✔ clave
{U}⁺ = {U}  →  por U → S: {U, S}  →  por U → N Y: {U, S, N, Y}
            →  por S → N Y U C: {S, N, Y, U, C}                          ✔ clave
```

Claves candidatas: **{S}** y **{U}**.

> `url` admite NULL. En la teoría {U} es clave candidata, pero en SQL no puede ser clave mientras admita nulos: `UNIQUE` permite varias filas con NULL. Esto se resuelve en el 1.3, decidiendo si `url` pasa a NOT NULL.

#### `producto` (P, N, M, Q, V, G, T)

Solo a la derecha: M, Q, V, T. En ambos lados: P, N, G. Núcleo: ∅.

```
Tamaño 1:
{P}⁺ = {P}  →  por P → N M Q V G T: {P, N, M, Q, V, G, T}                ✔ clave
{N}⁺ = {N}            ninguna DF tiene a N solo a la izquierda         ✘
{G}⁺ = {G}            ninguna DF tiene a G solo a la izquierda         ✘
Tamaño 2 (sin superconjuntos de {P}):
{N, G}⁺ = {N, G}  →  por N G → P: {N, G, P}
                  →  por P → N M Q V G T: {P, N, M, Q, V, G, T}          ✔ clave
```

Claves candidatas: **{P}** y **{N, G}**. {N, G} es mínima porque ni {N}⁺ ni {G}⁺ contienen todos los atributos.

#### `producto_reutilizable` (P, K, Z) y `producto_desechable` (P, A, R)

P aparece solo a la izquierda, así que el núcleo es {P}.

```
{P}⁺ = {P}  →  por P → K Z: {P, K, Z}    ✔ clave
{P}⁺ = {P}  →  por P → A R: {P, A, R}    ✔ clave
```

Clave candidata única: **{P}** en cada subtipo.

#### `producto_material` (P, M)

F no tiene dependencias no triviales, así que P y M no aparecen en ninguna. El núcleo es {P, M}.

```
{P, M}⁺ = {P, M}    ✔ clave (es todo el esquema)
```

Clave candidata única: **{P, M}**.

#### `impacto_ambiental` (I, P, S, A, E, C, R, N, D)

Solo a la derecha: A, E, C, R, N. En ambos lados: I, P, S, D. Núcleo: ∅.

```
Tamaño 1:
{I}⁺ = {I}  →  por I → P S A E C R N D: {I, P, S, A, E, C, R, N, D}       ✔ clave
{P}⁺ = {P}                                                              ✘
{S}⁺ = {S}                                                              ✘
{D}⁺ = {D}                                                              ✘
Tamaño 2 (sin superconjuntos de {I}):
{P, S}⁺ = {P, S}  →  por P S → I: {P, S, I}
                  →  por I → … : {I, P, S, A, E, C, R, N, D}              ✔ clave
{P, D}⁺ = {P, D}                                                        ✘
{S, D}⁺ = {S, D}                                                        ✘
Tamaño 3: {P, S, D} contiene a {P, S}, así que no es mínima y no se prueba.
```

Claves candidatas: **{I}** y **{P, S}**.

#### `usuario_ecodata` (U, N, C, H, F, A)

```
{U}⁺ = {U}  →  por U → N C H F A: {U, N, C, H, F, A}                       ✔ clave
{C}⁺ = {C}  →  por C → U: {C, U}  →  por U → N C H F A: {U, N, C, H, F, A}   ✔ clave
```

Claves candidatas: **{U}** y **{C}**.

#### `usuario_sesion_ecodata` (S, U, K, C, X)

```
{S}⁺ = {S}  →  por S → U K C X: {S, U, K, C, X}                          ✔ clave
{K}⁺ = {K}  →  por K → S: {K, S}  →  por S → U K C X: {S, U, K, C, X}      ✔ clave
```

Claves candidatas: **{S}** y **{K}**.

#### Resumen de claves

| Tabla | Claves candidatas | Clave primaria | ¿La otra clave está declarada? |
|---|---|---|---|
| categoria | {id_categoria}, {nombre} | id_categoria | No: falta `UNIQUE (nombre)` |
| pais | {id_pais}, {nombre} | id_pais | No: falta `UNIQUE (nombre)` |
| material | {id_material}, {nombre} | id_material | Sí: `uq_material_nombre` |
| fuente | {id_fuente}, {url} | id_fuente | Sí: `uq_fuente_url`, pero `url` admite NULL |
| producto | {id_producto}, {nombre, id_categoria} | id_producto | Sí: `uq_producto_nombre_categoria` |
| producto_reutilizable | {id_producto} | id_producto | — |
| producto_desechable | {id_producto} | id_producto | — |
| producto_material | {id_producto, id_material} | la misma | — |
| impacto_ambiental | {id_impacto}, {id_producto, id_fuente} | id_impacto | No: falta `UNIQUE (id_producto, id_fuente)` |
| usuario_ecodata | {id_usuario}, {correo} | id_usuario | Sí: índice único sobre `LOWER(correo)` |
| usuario_sesion_ecodata | {id_sesion}, {token_hash} | id_sesion | Sí: `token_hash UNIQUE` |

---

### 3. Reducción de F a un conjunto mínimo

Los pasos son tres:

1. **Lados derechos simples:** cada dependencia `X → A B` se separa en `X → A` y `X → B`.
2. **Sin atributos sobrantes:** en cada dependencia con lado izquierdo compuesto `X → A`, el atributo `B ∈ X` sobra si `A ∈ (X − B)⁺`, calculado con el F del paso 1.
3. **Sin dependencias redundantes:** `X → A` es redundante si `A ∈ X⁺`, calculado con F sin esa dependencia.

**El orden del paso 3 importa.** Un conjunto puede tener más de un cubrimiento mínimo. Por ejemplo, en `impacto_ambiental`, si se probara primero `I → A`, se eliminaría a cambio de conservar `P S → A`, y el resultado también sería mínimo. Aquí se prueban **primero las dependencias que no salen de la clave primaria**, para conservar las que salen de la clave que la base implementa.

Las tablas `categoria`, `pais`, `producto_reutilizable`, `producto_desechable`, `usuario_ecodata` y `usuario_sesion_ecodata` no pierden ninguna dependencia: después del paso 1 ya son mínimas. Al final de esta sección hay una tabla con los cierres que lo comprueban. Las eliminaciones ocurren en `material`, `fuente` e `impacto_ambiental`.

#### Paso 1. Lados derechos simples

| Tabla | F con lados derechos simples |
|---|---|
| categoria | G → N, G → D, N → G |
| pais | T → N, N → T |
| material | M → N, M → D, M → Y, M → R, N → M, N → Y |
| fuente | S → N, S → Y, S → U, S → C, U → S, U → N, U → Y |
| producto | P → N, P → M, P → Q, P → V, P → G, P → T, N G → P |
| producto_reutilizable | P → K, P → Z |
| producto_desechable | P → A, P → R |
| impacto_ambiental | I → P, I → S, I → A, I → E, I → C, I → R, I → N, I → D, P S → I, P S D → A, P S D → E, P S D → C, P S D → R, P S D → N |
| usuario_ecodata | U → N, U → C, U → H, U → F, U → A, C → U |
| usuario_sesion_ecodata | S → U, S → K, S → C, S → X, K → S |

#### Paso 2. Atributos sobrantes a la izquierda

Solo `producto` e `impacto_ambiental` tienen lados izquierdos compuestos.

**`producto`, N G → P**

```
¿Sobra N?  {G}⁺ = {G}   no contiene P  →  N se queda
¿Sobra G?  {N}⁺ = {N}   no contiene P  →  G se queda
```

No hay atributos sobrantes. Esto confirma que la regla RN12 necesita las dos columnas: el nombre solo no identifica al producto.

**`impacto_ambiental`, P S → I**

```
¿Sobra P?  {S}⁺ = {S}   no contiene I  →  P se queda
¿Sobra S?  {P}⁺ = {P}   no contiene I  →  S se queda
```

**`impacto_ambiental`, P S D → A** (el razonamiento es el mismo para E, C, R y N)

```
¿Sobra P?  {S, D}⁺ = {S, D}   no contiene A  →  P se queda
¿Sobra S?  {P, D}⁺ = {P, D}   no contiene A  →  S se queda
¿Sobra D?  {P, S}⁺ = {P, S} → por P S → I: {P, S, I}
                    → por I → A, E, C, R, N, D: {I, P, S, A, E, C, R, N, D}
           contiene A  →  D SOBRA
```

**Eliminación 1.** Se quita `D` del lado izquierdo de `P S D → A`, `P S D → E`, `P S D → C`, `P S D → R` y `P S D → N`, que quedan como `P S → A`, `P S → E`, `P S → C`, `P S → R` y `P S → N`. La fecha del dato no aporta nada para determinar los indicadores: como una fuente aporta un solo registro por producto (RN17), ese registro ya fija su fecha.

#### Paso 3. Dependencias redundantes

**`material`**

```
N → M:  {N}⁺ sin N → M = {N} → por N → Y: {N, Y}           no contiene M  →  se conserva
N → Y:  {N}⁺ sin N → Y = {N} → por N → M: {N, M}
                         → por M → N, D, Y, R: {M, N, D, Y, R}
        contiene Y  →  REDUNDANTE
```

**Eliminación 2.** Se quita `N → Y`. La familia del material ya se deduce de su nombre por transitividad: `N → M` y `M → Y`.

```
M → N:  {M}⁺ sin ella = {M, D, Y, R}   no contiene N  →  se conserva
M → D:  {M}⁺ sin ella = {M, N, Y, R}   no contiene D  →  se conserva
M → Y:  {M}⁺ sin ella = {M, N, D, R}   no contiene Y  →  se conserva
M → R:  {M}⁺ sin ella = {M, N, D, Y}   no contiene R  →  se conserva
```

**`fuente`**

```
U → S:  {U}⁺ sin U → S = {U} → por U → N, U → Y: {U, N, Y}   no contiene S  →  se conserva
U → N:  {U}⁺ sin U → N = {U} → por U → S: {U, S}
                         → por S → N, Y, U, C: {S, N, Y, U, C}
        contiene N  →  REDUNDANTE
```

**Eliminación 3.** Se quita `U → N`.

```
U → Y:  {U}⁺ sin U → Y (y ya sin U → N) = {U} → por U → S: {U, S}
                                         → por S → N, Y, U, C: {S, N, Y, U, C}
        contiene Y  →  REDUNDANTE
```

**Eliminación 4.** Se quita `U → Y`. El título y el tipo se obtienen pasando por la fuente: `U → S` y `S → N Y`.

```
S → N:  {S}⁺ sin ella = {S, Y, U, C}   no contiene N  →  se conserva
S → Y:  {S}⁺ sin ella = {S, N, U, C}   no contiene Y  →  se conserva
S → U:  {S}⁺ sin ella = {S, N, Y, C}   no contiene U  →  se conserva
S → C:  {S}⁺ sin ella = {S, N, Y, U}   no contiene C  →  se conserva
```

**`impacto_ambiental`**, partiendo del resultado del paso 2

```
P S → I:  {P, S}⁺ sin ella = {P, S} → por P S → A, E, C, R, N: {P, S, A, E, C, R, N}
          no contiene I  →  se conserva
P S → A:  {P, S}⁺ sin ella = {P, S} → por P S → I: {P, S, I}
                           → por I → A, …: {I, P, S, A, E, C, R, N, D}
          contiene A  →  REDUNDANTE
```

**Eliminaciones 5 a 9.** Se quitan `P S → A`, `P S → E`, `P S → C`, `P S → R` y `P S → N`. Para cada una, el cierre de {P, S} sin ella sigue siendo {I, P, S, A, E, C, R, N, D}, porque pasa por `P S → I` y luego por `I → …`. En otras palabras, RN18 no agrega nada que no estuviera ya en RN16 más RN17.

```
I → P:  {I}⁺ sin ella = {I, S, A, E, C, R, N, D}   no contiene P  →  se conserva
I → S:  {I}⁺ sin ella = {I, P, A, E, C, R, N, D}   no contiene S  →  se conserva
I → A … I → D:  al quitar cualquiera, ese atributo desaparece de {I}⁺  →  se conservan
```

> `I → P` e `I → S` no se pueden derivar de `P S → I`, porque esta necesita a P y a S en el lado izquierdo para empezar.

**Tablas que no pierden ninguna dependencia.** En todas, el cierre del lado izquierdo, calculado sin la dependencia, no contiene el lado derecho:

| Tabla | Comprobación |
|---|---|
| categoria | N → G: {N}⁺ = {N}. G → N: {G}⁺ = {G, D}. G → D: {G}⁺ = {G, N}. |
| pais | N → T: {N}⁺ = {N}. T → N: {T}⁺ = {T}. |
| producto | N G → P: {N, G}⁺ = {N, G}. Para cada P → X, {P}⁺ sin ella contiene todo menos X. |
| producto_reutilizable | P → K: {P}⁺ = {P, Z}. P → Z: {P}⁺ = {P, K}. |
| producto_desechable | P → A: {P}⁺ = {P, R}. P → R: {P}⁺ = {P, A}. |
| usuario_ecodata | C → U: {C}⁺ = {C}. Para cada U → X, {U}⁺ sin ella contiene todo menos X. |
| usuario_sesion_ecodata | K → S: {K}⁺ = {K}. Para cada S → X, {S}⁺ sin ella contiene todo menos X. |

#### Cubrimiento mínimo F<sub>min</sub>

| Tabla | F<sub>min</sub> |
|---|---|
| categoria | G → N, G → D, N → G |
| pais | T → N, N → T |
| material | M → N, M → D, M → Y, M → R, N → M |
| fuente | S → N, S → Y, S → U, S → C, U → S |
| producto | P → N, P → M, P → Q, P → V, P → G, P → T, N G → P |
| producto_reutilizable | P → K, P → Z |
| producto_desechable | P → A, P → R |
| producto_material | ∅ (solo dependencias triviales) |
| impacto_ambiental | I → P, I → S, I → A, I → E, I → C, I → R, I → N, I → D, P S → I |
| usuario_ecodata | U → N, U → C, U → H, U → F, U → A, C → U |
| usuario_sesion_ecodata | S → U, S → K, S → C, S → X, K → S |

En total hubo nueve eliminaciones: el atributo sobrante `D` en RN18 y ocho dependencias redundantes (`N → Y`, `U → N`, `U → Y` y las cinco `P S → {A, E, C, R, N}`).

**Comprobación de F ≡ F<sub>min</sub>.** F<sub>min</sub> ⊆ F⁺ porque se obtuvo de F. Además, cada dependencia original se deduce de F<sub>min</sub>:

| DF de F | Cierre bajo F<sub>min</sub> | ¿Se deduce? |
|---|---|---|
| material: N → Y | {N}⁺ = {M, N, D, Y, R} | Sí |
| fuente: U → N Y | {U}⁺ = {S, N, Y, U, C} | Sí |
| impacto_ambiental: P S D → A E C R N | {P, S, D}⁺ = {I, P, S, A, E, C, R, N, D} | Sí |
| El resto | Están en F<sub>min</sub> tal cual o separadas por el paso 1 | Sí |

---

### 4. Equivalencia con el F de otro equipo

**Equipo con el que se intercambió:** _(pendiente: nombre del equipo)_. Su conjunto se guarda en `dependencias/G-<equipo>.txt` con el mismo formato que `F-ecodata.txt`. Los nombres de tabla y de columna deben ser los mismos; las letras pueden cambiar.

**Método.** Dos conjuntos F y G son equivalentes si cada uno cubre al otro:

- **F cubre a G:** para cada `X → Y` de G, `Y ⊆ X⁺` calculado con F.
- **G cubre a F:** para cada `X → Y` de F, `Y ⊆ X⁺` calculado con G.

Si alguna dependencia no se deduce, los conjuntos no son equivalentes. Esa dependencia indica qué regla del negocio interpretó distinto cada equipo, y es lo que se discute con ellos.

```bash
python3 practica6-8/dependencias/dependencias.py \
        practica6-8/dependencias/F-ecodata.txt \
        practica6-8/dependencias/G-<equipo>.txt
```

| Tabla | ¿F cubre a G? | ¿G cubre a F? | Resultado | DF que no se deduce y regla en discusión |
|---|---|---|---|---|
| categoria | | | | |
| pais | | | | |
| material | | | | |
| fuente | | | | |
| producto | | | | |
| producto_reutilizable | | | | |
| producto_desechable | | | | |
| producto_material | | | | |
| impacto_ambiental | | | | |
| usuario_ecodata | | | | |
| usuario_sesion_ecodata | | | | |

**Diferencias que conviene revisar primero**, porque son las reglas más fáciles de interpretar distinto:

- Si el otro equipo escribió `nombre → id_producto`, su G **no** está cubierto por nuestro F: {N}⁺ = {N}. La discusión es si el nombre del producto es único en toda la tabla o solo dentro de la categoría (RN12).
- Si no incluyó `P S → I` en `impacto_ambiental`, nuestro F no está cubierto por su G. La discusión es RN17: si una fuente puede tener varios registros del mismo producto.
- Si incluyó `emisiones_co2 → nivel_impacto`, es la dependencia que en la sección 1 se descartó por ser una clasificación relativa al estudio.

**Conclusión:** _(pendiente: equivalentes / no equivalentes, y por qué)._

---

### Qué pasa al ejercicio 1.3

En F<sub>min</sub>, el lado izquierdo de cada dependencia es una clave candidata de su tabla: {G}, {N}, {T}, {M}, {S}, {U}, {P}, {N, G}, {I}, {P, S}, {C} y {K}. Una tabla cumple BCNF cuando el lado izquierdo de toda dependencia no trivial es superclave. Por eso **el esquema actual de EcoData ya está en BCNF**, y el 1.3 se resolverá por la vía que prevé la práctica: demostrarlo y normalizar una tabla desnormalizada a propósito.

Lo que sí sale de este análisis son restricciones que faltan en la base:

- `UNIQUE (nombre)` en `categoria` y en `pais`.
- `UNIQUE (id_producto, id_fuente)` en `impacto_ambiental`.
- Decidir si `fuente.url` pasa a NOT NULL para que {url} sea clave candidata también en SQL.
