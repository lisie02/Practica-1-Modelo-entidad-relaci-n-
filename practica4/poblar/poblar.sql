-- Practica 4 - Ejercicio 1.4
-- Carga automatizada y repetible de EcoData.
-- El archivo CSV se copia previamente a /tmp/envases_355ml.csv
-- dentro del contenedor practica1.

BEGIN;

CREATE TEMP TABLE stg_envases (
    material TEXT,
    energia_mj NUMERIC(12,2),
    huella_carbono_kg_co2e NUMERIC(12,6),
    acidificacion_mol_h_e NUMERIC,
    eutrofizacion_kg_n_e NUMERIC
) ON COMMIT DROP;

\copy stg_envases FROM '/tmp/envases_355ml.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

CREATE TEMP TABLE resumen_carga (
    tabla TEXT,
    filas_archivo INTEGER,
    insertados INTEGER,
    omitidos INTEGER,
    rechazados INTEGER
) ON COMMIT DROP;

DO $$
DECLARE
    v_detalle TEXT;
    v_total INTEGER;
    v_insertados INTEGER;
BEGIN
    -- Validar los datos antes de modificar las tablas definitivas.
    SELECT string_agg(
        format(
            'material=%s: %s',
            COALESCE(NULLIF(BTRIM(material), ''), '(vacio)'),
            concat_ws(', ',
                CASE WHEN material IS NULL
                    OR BTRIM(material) NOT IN ('PET','Vidrio','Aluminio')
                    THEN 'material no reconocido' END,
                CASE WHEN energia_mj IS NULL OR energia_mj < 0
                    THEN 'energia nula o negativa' END,
                CASE WHEN huella_carbono_kg_co2e IS NULL
                    OR huella_carbono_kg_co2e < 0
                    THEN 'huella de carbono nula o negativa' END,
                CASE WHEN acidificacion_mol_h_e IS NULL
                    OR acidificacion_mol_h_e < 0
                    THEN 'acidificacion nula o negativa' END,
                CASE WHEN eutrofizacion_kg_n_e IS NULL
                    OR eutrofizacion_kg_n_e < 0
                    THEN 'eutrofizacion nula o negativa' END
            )
        ),
        ' | '
    )
    INTO v_detalle
    FROM stg_envases
    WHERE material IS NULL
       OR BTRIM(material) NOT IN ('PET','Vidrio','Aluminio')
       OR energia_mj IS NULL OR energia_mj < 0
       OR huella_carbono_kg_co2e IS NULL
       OR huella_carbono_kg_co2e < 0
       OR acidificacion_mol_h_e IS NULL
       OR acidificacion_mol_h_e < 0
       OR eutrofizacion_kg_n_e IS NULL
       OR eutrofizacion_kg_n_e < 0;

    IF v_detalle IS NOT NULL THEN
        RAISE EXCEPTION 'Carga cancelada. Filas invalidas: %', v_detalle;
    END IF;

    IF (SELECT COUNT(*) FROM stg_envases) <> 3 THEN
        RAISE EXCEPTION
            'Carga cancelada: se esperaban 3 filas y se recibieron %.',
            (SELECT COUNT(*) FROM stg_envases);
    END IF;

    IF EXISTS (
        SELECT material
        FROM stg_envases
        GROUP BY material
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION
            'Carga cancelada: el CSV contiene materiales duplicados.';
    END IF;

    -- 1. Categoria.
    INSERT INTO categoria (nombre, descripcion)
    SELECT 'Envases para bebidas',
           'Envases utilizados para contener bebidas.'
    WHERE NOT EXISTS (
        SELECT 1 FROM categoria
        WHERE BTRIM(nombre) = 'Envases para bebidas'
    );

    GET DIAGNOSTICS v_insertados = ROW_COUNT;
    INSERT INTO resumen_carga
    VALUES ('categoria', 1, v_insertados, 1-v_insertados, 0);

    -- 2. Fuente bibliografica.
    INSERT INTO fuente (nombre, tipo, url, fecha_consulta)
    SELECT
        'UANL - Sustentabilidad de materiales para envasado de refrescos',
        'Articulo cientifico',
        'https://doi.org/10.29105/ingenierias27.96-947',
        CURRENT_DATE
    WHERE NOT EXISTS (
        SELECT 1 FROM fuente
        WHERE url = 'https://doi.org/10.29105/ingenierias27.96-947'
    );

    GET DIAGNOSTICS v_insertados = ROW_COUNT;
    INSERT INTO resumen_carga
    VALUES ('fuente', 1, v_insertados, 1-v_insertados, 0);

    -- 3. Materiales.
    SELECT COUNT(DISTINCT material)
    INTO v_total
    FROM stg_envases;

    INSERT INTO material (nombre, descripcion, tipo)
    SELECT DISTINCT
        s.material,
        CASE s.material
            WHEN 'PET' THEN 'Polietileno tereftalato utilizado en envases.'
            WHEN 'Vidrio' THEN 'Material utilizado en envases de bebidas.'
            WHEN 'Aluminio' THEN 'Metal utilizado en envases de bebidas.'
        END,
        CASE s.material
            WHEN 'PET' THEN 'Plastico'
            WHEN 'Vidrio' THEN 'Vidrio'
            WHEN 'Aluminio' THEN 'Metal'
        END
    FROM stg_envases s
    WHERE NOT EXISTS (
        SELECT 1 FROM material m
        WHERE BTRIM(m.nombre) = s.material
    );

    GET DIAGNOSTICS v_insertados = ROW_COUNT;
    INSERT INTO resumen_carga
    VALUES ('material', v_total, v_insertados,
            v_total-v_insertados, 0);

    -- 4. Productos.
    SELECT COUNT(*) INTO v_total FROM stg_envases;

    INSERT INTO producto
        (nombre, marca, precio_aproximado, vida_util,
         id_categoria, id_pais)
    SELECT
        CASE s.material
            WHEN 'PET' THEN 'Botella PET para refresco de 355 ml'
            WHEN 'Vidrio' THEN 'Envase de vidrio para refresco de 355 ml'
            WHEN 'Aluminio' THEN 'Lata de aluminio para refresco de 355 ml'
        END,
        'Coca-Cola',
        NULL,
        NULL,
        c.id_categoria,
        NULL
    FROM stg_envases s
    CROSS JOIN categoria c
    WHERE BTRIM(c.nombre) = 'Envases para bebidas'
      AND NOT EXISTS (
          SELECT 1 FROM producto p
          WHERE p.nombre = CASE s.material
              WHEN 'PET' THEN 'Botella PET para refresco de 355 ml'
              WHEN 'Vidrio' THEN 'Envase de vidrio para refresco de 355 ml'
              WHEN 'Aluminio' THEN 'Lata de aluminio para refresco de 355 ml'
          END
      );

    GET DIAGNOSTICS v_insertados = ROW_COUNT;
    INSERT INTO resumen_carga
    VALUES ('producto', v_total, v_insertados,
            v_total-v_insertados, 0);

    -- 5. Relacion producto-material.
    SELECT COUNT(*) INTO v_total FROM stg_envases;

    INSERT INTO producto_material (id_producto, id_material)
    SELECT p.id_producto, m.id_material
    FROM stg_envases s
    JOIN material m ON BTRIM(m.nombre) = s.material
    JOIN producto p ON p.nombre = CASE s.material
        WHEN 'PET' THEN 'Botella PET para refresco de 355 ml'
        WHEN 'Vidrio' THEN 'Envase de vidrio para refresco de 355 ml'
        WHEN 'Aluminio' THEN 'Lata de aluminio para refresco de 355 ml'
    END
    WHERE NOT EXISTS (
        SELECT 1 FROM producto_material pm
        WHERE pm.id_producto = p.id_producto
          AND pm.id_material = m.id_material
    );

    GET DIAGNOSTICS v_insertados = ROW_COUNT;
    INSERT INTO resumen_carga
    VALUES ('producto_material', v_total, v_insertados,
            v_total-v_insertados, 0);

    -- 6. Impactos ambientales.
    SELECT COUNT(*) INTO v_total FROM stg_envases;

    INSERT INTO impacto_ambiental
        (id_producto, id_fuente, consumo_energia,
         emisiones_co2, nivel_impacto)
    SELECT
        p.id_producto,
        f.id_fuente,
        s.energia_mj,
        s.huella_carbono_kg_co2e,
        CASE s.material
            WHEN 'PET' THEN 'Bajo (caso nacional)'
            WHEN 'Vidrio' THEN 'Alto (caso nacional)'
            WHEN 'Aluminio' THEN 'Medio (caso nacional)'
        END
    FROM stg_envases s
    JOIN producto p ON p.nombre = CASE s.material
        WHEN 'PET' THEN 'Botella PET para refresco de 355 ml'
        WHEN 'Vidrio' THEN 'Envase de vidrio para refresco de 355 ml'
        WHEN 'Aluminio' THEN 'Lata de aluminio para refresco de 355 ml'
    END
    JOIN fuente f
      ON f.url = 'https://doi.org/10.29105/ingenierias27.96-947'
    WHERE NOT EXISTS (
        SELECT 1 FROM impacto_ambiental i
        WHERE i.id_producto = p.id_producto
          AND i.id_fuente = f.id_fuente
          AND i.consumo_energia = s.energia_mj
          AND i.emisiones_co2 = s.huella_carbono_kg_co2e
    );

    GET DIAGNOSTICS v_insertados = ROW_COUNT;
    INSERT INTO resumen_carga
    VALUES ('impacto_ambiental', v_total, v_insertados,
            v_total-v_insertados, 0);

END;
$$;

SELECT tabla, filas_archivo, insertados, omitidos, rechazados
FROM resumen_carga
ORDER BY tabla;

COMMIT;
