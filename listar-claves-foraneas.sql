-- Ejercicio 2.1: lista las claves foráneas del esquema public de EcoData.
-- on_delete / on_update: a = NO ACTION, r = RESTRICT, c = CASCADE, n = SET NULL, d = SET DEFAULT
SELECT
    con.conname                       AS restriccion,
    con.conrelid::regclass            AS tabla_hija,
    att.attname                       AS columna,
    con.confrelid::regclass           AS tabla_padre,
    att_ref.attname                   AS columna_referenciada,
    NOT att.attnotnull                AS admite_null,
    con.confdeltype                   AS on_delete,
    con.confupdtype                   AS on_update
FROM pg_constraint con
JOIN pg_attribute att
  ON att.attrelid = con.conrelid AND att.attnum = ANY (con.conkey)
JOIN pg_attribute att_ref
  ON att_ref.attrelid = con.confrelid AND att_ref.attnum = ANY (con.confkey)
WHERE con.contype = 'f'
  AND con.connamespace = 'public'::regnamespace
ORDER BY tabla_hija::text, columna;
