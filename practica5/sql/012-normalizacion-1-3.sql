
-- PRACTICA 1.3: DEMOSTRACION DE NORMALIZACION
-- Proyecto EcoData
-- Tabla desnormalizada para analizar dependencias funcionales.

CREATE TABLE IF NOT EXISTS public.practica_13_desnormalizada (
    id_reporte INTEGER PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    marca VARCHAR(100),
    id_categoria INTEGER NOT NULL,
    nombre_categoria VARCHAR(100) NOT NULL,
    id_fuente INTEGER NOT NULL,
    nombre_fuente VARCHAR(200) NOT NULL,
    emisiones_co2 NUMERIC(12,6),
    consumo_energia NUMERIC(12,2),
    nivel_impacto VARCHAR(50)
);

-- Cargar los datos reales de EcoData.
INSERT INTO public.practica_13_desnormalizada (
    id_reporte,
    id_producto,
    nombre_producto,
    marca,
    id_categoria,
    nombre_categoria,
    id_fuente,
    nombre_fuente,
    emisiones_co2,
    consumo_energia,
    nivel_impacto
)
SELECT
    ia.id_impacto,
    p.id_producto,
    p.nombre,
    p.marca,
    c.id_categoria,
    c.nombre,
    f.id_fuente,
    f.nombre,
    ia.emisiones_co2,
    ia.consumo_energia,
    ia.nivel_impacto
FROM public.impacto_ambiental ia
JOIN public.producto p
    ON p.id_producto = ia.id_producto
JOIN public.categoria c
    ON c.id_categoria = p.id_categoria
JOIN public.fuente f
    ON f.id_fuente = ia.id_fuente
ON CONFLICT (id_reporte) DO NOTHING;

-- Consultar la tabla desnormalizada.
SELECT *
FROM public.practica_13_desnormalizada
ORDER BY id_reporte;
