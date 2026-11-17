-- EcoData: tablas para el registro y las sesiones de usuarios.
-- Ejecutar una sola vez en la base de datos ecodata.
-- No modifica las nueve tablas existentes del proyecto.

BEGIN;

CREATE TABLE IF NOT EXISTS public.usuario_ecodata (
    id_usuario BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(254) NOT NULL,
    password_hash TEXT NOT NULL,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_usuario_nombre_no_vacio CHECK (BTRIM(nombre) <> ''),
    CONSTRAINT chk_usuario_correo_no_vacio CHECK (BTRIM(correo) <> ''),
    CONSTRAINT chk_usuario_password_hash_no_vacio CHECK (BTRIM(password_hash) <> '')
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_usuario_ecodata_correo
    ON public.usuario_ecodata (LOWER(correo));

CREATE TABLE IF NOT EXISTS public.usuario_sesion_ecodata (
    id_sesion BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario BIGINT NOT NULL
        REFERENCES public.usuario_ecodata(id_usuario) ON DELETE CASCADE,
    token_hash CHAR(64) NOT NULL UNIQUE,
    creada_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expira_en TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_usuario_sesion_expiracion CHECK (expira_en > creada_en)
);

CREATE INDEX IF NOT EXISTS idx_usuario_sesion_expira_en
    ON public.usuario_sesion_ecodata(expira_en);

COMMIT;
