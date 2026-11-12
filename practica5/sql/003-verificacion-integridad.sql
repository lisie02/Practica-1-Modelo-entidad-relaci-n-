-- Practica 5 - Ejercicio 2.3
-- Verificacion de integridad referencial, UNIQUE y NOT NULL.
-- Consultas de solo lectura.
-- Ejecutar en ecodata y obras_publicas.

-- ==========================================================
-- 1. CLAVES FORANEAS HUERFANAS
-- ==========================================================

DO $$
DECLARE
    r RECORD;
    v_join TEXT;
    v_no_nulos TEXT;
    v_total BIGINT := 0;
    v_cantidad BIGINT;
BEGIN
    FOR r IN
        SELECT
            c.conname,
            c.conrelid,
            c.confrelid,
            c.conkey,
            c.confkey
        FROM pg_constraint c
        JOIN pg_namespace n ON n.oid = c.connamespace
        WHERE c.contype = 'f'
          AND n.nspname IN ('public', 'warehouse')
        ORDER BY n.nspname, c.conname
    LOOP
        SELECT
            string_agg(
                format('h.%I = p.%I', ah.attname, ap.attname),
                ' AND ' ORDER BY kh.ord
            ),
            string_agg(
                format('h.%I IS NOT NULL', ah.attname),
                ' AND ' ORDER BY kh.ord
            )
        INTO v_join, v_no_nulos
        FROM unnest(r.conkey) WITH ORDINALITY kh(attnum, ord)
        JOIN pg_attribute ah
          ON ah.attrelid = r.conrelid
         AND ah.attnum = kh.attnum
        JOIN unnest(r.confkey) WITH ORDINALITY kp(attnum, ord)
          ON kp.ord = kh.ord
        JOIN pg_attribute ap
          ON ap.attrelid = r.confrelid
         AND ap.attnum = kp.attnum;

        EXECUTE format(
            'SELECT COUNT(*)
             FROM %s h
             WHERE %s
               AND NOT EXISTS (
                   SELECT 1 FROM %s p WHERE %s
               )',
            r.conrelid::regclass,
            v_no_nulos,
            r.confrelid::regclass,
            v_join
        )
        INTO v_cantidad;

        IF v_cantidad > 0 THEN
            RAISE WARNING
                'FK % en %: % registros huerfanos',
                r.conname, r.conrelid::regclass, v_cantidad;
            v_total := v_total + v_cantidad;
        END IF;
    END LOOP;

    IF v_total = 0 THEN
        RAISE NOTICE 'CORRECTO: no se encontraron claves foraneas huerfanas.';
    ELSE
        RAISE WARNING 'Total de referencias huerfanas: %', v_total;
    END IF;
END;
$$;

-- ==========================================================
-- 2. VALORES DUPLICADOS EN CLAVES PRIMARIAS Y UNIQUE
-- ==========================================================

DO $$
DECLARE
    r RECORD;
    v_columnas TEXT;
    v_filtro TEXT;
    v_total BIGINT := 0;
    v_cantidad BIGINT;
BEGIN
    FOR r IN
        SELECT
            c.conname,
            c.conrelid,
            c.conkey,
            c.contype,
            COALESCE(i.indnullsnotdistinct, FALSE) AS nulls_no_distintos
        FROM pg_constraint c
        JOIN pg_namespace n ON n.oid = c.connamespace
        LEFT JOIN pg_index i ON i.indexrelid = c.conindid
        WHERE c.contype IN ('p', 'u')
          AND n.nspname IN ('public', 'warehouse')
        ORDER BY n.nspname, c.conname
    LOOP
        SELECT string_agg(
            format('%I', a.attname),
            ', ' ORDER BY k.ord
        )
        INTO v_columnas
        FROM unnest(r.conkey) WITH ORDINALITY k(attnum, ord)
        JOIN pg_attribute a
          ON a.attrelid = r.conrelid
         AND a.attnum = k.attnum;

        IF r.contype = 'p' OR r.nulls_no_distintos THEN
            v_filtro := 'TRUE';
        ELSE
            SELECT string_agg(
                format('%I IS NOT NULL', a.attname),
                ' AND ' ORDER BY k.ord
            )
            INTO v_filtro
            FROM unnest(r.conkey) WITH ORDINALITY k(attnum, ord)
            JOIN pg_attribute a
              ON a.attrelid = r.conrelid
             AND a.attnum = k.attnum;
        END IF;

        EXECUTE format(
            'SELECT COUNT(*) FROM (
                 SELECT 1 FROM %s
                 WHERE %s
                 GROUP BY %s
                 HAVING COUNT(*) > 1
             ) duplicados',
            r.conrelid::regclass,
            v_filtro,
            v_columnas
        )
        INTO v_cantidad;

        IF v_cantidad > 0 THEN
            RAISE WARNING
                'UNIQUE/PK % en %: % grupos duplicados',
                r.conname, r.conrelid::regclass, v_cantidad;
            v_total := v_total + v_cantidad;
        END IF;
    END LOOP;

    IF v_total = 0 THEN
        RAISE NOTICE 'CORRECTO: no se encontraron duplicados en PK y UNIQUE.';
    ELSE
        RAISE WARNING 'Total de grupos duplicados: %', v_total;
    END IF;
END;
$$;

-- ==========================================================
-- 3. NULOS EN COLUMNAS NOT NULL
-- ==========================================================

DO $$
DECLARE
    r RECORD;
    v_total BIGINT := 0;
    v_cantidad BIGINT;
BEGIN
    FOR r IN
        SELECT
            c.oid AS relid,
            a.attname
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        WHERE n.nspname IN ('public', 'warehouse')
          AND c.relkind IN ('r', 'p')
          AND NOT c.relispartition
          AND a.attnum > 0
          AND NOT a.attisdropped
          AND a.attnotnull
        ORDER BY n.nspname, c.relname, a.attnum
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM %s WHERE %I IS NULL',
            r.relid::regclass,
            r.attname
        )
        INTO v_cantidad;

        IF v_cantidad > 0 THEN
            RAISE WARNING
                'NOT NULL: columna %.% tiene % nulos',
                r.relid::regclass, r.attname, v_cantidad;
            v_total := v_total + v_cantidad;
        END IF;
    END LOOP;

    IF v_total = 0 THEN
        RAISE NOTICE 'CORRECTO: no se encontraron nulos en columnas NOT NULL.';
    ELSE
        RAISE WARNING 'Total de valores nulos prohibidos: %', v_total;
    END IF;
END;
$$;

\echo 'FIN: verificaciones de integridad terminadas.'
