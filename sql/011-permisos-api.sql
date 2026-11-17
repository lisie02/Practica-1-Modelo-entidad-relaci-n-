-- Ejecutar como administrador (rol lis) en la base ecodata.
-- Crea un rol de aplicación con privilegios mínimos para el sitio web.
-- Después de ejecutar este archivo, asigna una contraseña con \password ecodata_web.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ecodata_web') THEN
        CREATE ROLE ecodata_web LOGIN;
    END IF;
END;
$$;

GRANT CONNECT ON DATABASE ecodata TO ecodata_web;
GRANT USAGE ON SCHEMA public TO ecodata_web;

GRANT SELECT ON
    public.categoria,
    public.pais,
    public.material,
    public.fuente,
    public.producto,
    public.producto_material,
    public.impacto_ambiental,
    public.producto_reutilizable,
    public.producto_desechable
TO ecodata_web;

GRANT SELECT, INSERT ON public.usuario_ecodata TO ecodata_web;
GRANT SELECT, INSERT, DELETE ON public.usuario_sesion_ecodata TO ecodata_web;
GRANT USAGE, SELECT ON SEQUENCE
    public.usuario_ecodata_id_usuario_seq,
    public.usuario_sesion_ecodata_id_sesion_seq
TO ecodata_web;
