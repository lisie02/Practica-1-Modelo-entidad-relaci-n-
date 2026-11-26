
-- =========================================================
-- PRACTICA 1.3: NORMALIZACION HASTA TERCERA FORMA NORMAL
-- Proyecto: EcoData
-- Base de datos: ecodata_pruebas
-- =========================================================

BEGIN;

-- =========================================================
-- 1. CREAR TABLA DE CATEGORIAS
-- =========================================================

CREATE TABLE IF NOT EXISTS public.categoria_3fn (
    id_categoria INTEGER PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL
);

-- =========================================================
-- 2. CREAR TABLA DE PRODUCTOS
-- =========================================================

CREATE TABLE IF NOT EXISTS public.producto_3fn (
    id_producto INTEGER PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    marca VARCHAR(100),
    id_categoria INTEGER NOT NULL,

    CONSTRAINT fk_producto_categoria_3fn
        FOREIGN KEY (id_categoria)
        REFERENCES public.categoria_3fn(id_categoria)
);

-- =========================================================
-- 3. CREAR TABLA DE FUENTES
-- =========================================================

CREATE TABLE IF NOT EXISTS public.fuente_3fn (
    id_fuente INTEGER PRIMARY KEY,
    nombre_fuente VARCHAR(200) NOT NULL
);

-- =========================================================
-- 4. CREAR TABLA DE REPORTES AMBIENTALES
-- =========================================================

CREATE TABLE IF NOT EXISTS public.reporte_3fn (
    id_reporte INTEGER PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    id_fuente INTEGER NOT NULL,
    emisiones_co2 NUMERIC(12,6),
    consumo_energia NUMERIC(12,2),
    nivel_impacto VARCHAR(50),

    CONSTRAINT fk_reporte_producto_3fn
        FOREIGN KEY (id_producto)
        REFERENCES public.producto_3fn(id_producto),

    CONSTRAINT fk_reporte_fuente_3fn
        FOREIGN KEY (id_fuente)
        REFERENCES public.fuente_3fn(id_fuente)
);

-- =========================================================
-- 5. INSERTAR CATEGORIAS
-- =========================================================

INSERT INTO public.categoria_3fn (
    id_categoria,
    nombre_categoria
)
SELECT DISTINCT
    id_categoria,
    nombre_categoria
FROM public.practica_13_desnormalizada
ON CONFLICT (id_categoria) DO NOTHING;

-- =========================================================
-- 6. INSERTAR PRODUCTOS
-- =========================================================

INSERT INTO public.producto_3fn (
    id_producto,
    nombre_producto,
    marca,
    id_categoria
)
SELECT DISTINCT
    id_producto,
    nombre_producto,
    marca,
    id_categoria
FROM public.practica_13_desnormalizada
ON CONFLICT (id_producto) DO NOTHING;

-- =========================================================
-- 7. INSERTAR FUENTES
-- =========================================================

INSERT INTO public.fuente_3fn (
    id_fuente,
    nombre_fuente
)
SELECT DISTINCT
    id_fuente,
    nombre_fuente
FROM public.practica_13_desnormalizada
ON CONFLICT (id_fuente) DO NOTHING;

-- =========================================================
-- 8. INSERTAR REPORTES AMBIENTALES
-- =========================================================

INSERT INTO public.reporte_3fn (
    id_reporte,
    id_producto,
    id_fuente,
    emisiones_co2,
    consumo_energia,
    nivel_impacto
)
SELECT
    id_reporte,
    id_producto,
    id_fuente,
    emisiones_co2,
    consumo_energia,
    nivel_impacto
FROM public.practica_13_desnormalizada
ON CONFLICT (id_reporte) DO NOTHING;

COMMIT;

-- =========================================================
-- 9. VERIFICAR LOS REGISTROS INSERTADOS
-- =========================================================

SELECT 'CATEGORIAS' AS tabla, COUNT(*) AS registros
FROM public.categoria_3fn

UNION ALL

SELECT 'PRODUCTOS', COUNT(*)
FROM public.producto_3fn

UNION ALL

SELECT 'FUENTES', COUNT(*)
FROM public.fuente_3fn

UNION ALL

SELECT 'REPORTES', COUNT(*)
FROM public.reporte_3fn;

-- =========================================================
-- 10. RECONSTRUIR LA INFORMACION MEDIANTE JOIN
-- =========================================================

SELECT
    r.id_reporte,
    p.id_producto,
    p.nombre_producto,
    p.marca,
    c.id_categoria,
    c.nombre_categoria,
    f.id_fuente,
    f.nombre_fuente,
    r.emisiones_co2,
    r.consumo_energia,
    r.nivel_impacto

FROM public.reporte_3fn r

INNER JOIN public.producto_3fn p
    ON r.id_producto = p.id_producto

INNER JOIN public.categoria_3fn c
    ON p.id_categoria = c.id_categoria

INNER JOIN public.fuente_3fn f
    ON r.id_fuente = f.id_fuente

ORDER BY r.id_reporte;
