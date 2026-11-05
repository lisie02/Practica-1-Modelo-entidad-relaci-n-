-- Practica 4 - Ejercicio 1.6
-- Creacion de roles y usuarios de EcoData.

-- Roles grupales.
SELECT 'CREATE ROLE rol_ecodata_app NOLOGIN'
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'rol_ecodata_app'
) \gexec

SELECT 'CREATE ROLE rol_ecodata_consulta NOLOGIN'
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'rol_ecodata_consulta'
) \gexec

SELECT 'CREATE ROLE rol_ecodata_admin NOLOGIN'
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'rol_ecodata_admin'
) \gexec

-- Usuarios individuales. Las contrasenas se configuraran aparte.
SELECT 'CREATE ROLE usr_ecodata_app LOGIN INHERIT'
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'usr_ecodata_app'
) \gexec

SELECT 'CREATE ROLE usr_ecodata_consulta LOGIN INHERIT'
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'usr_ecodata_consulta'
) \gexec

SELECT 'CREATE ROLE usr_ecodata_admin LOGIN INHERIT'
WHERE NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'usr_ecodata_admin'
) \gexec

-- Asociar cada usuario con su rol.
GRANT rol_ecodata_app TO usr_ecodata_app;
GRANT rol_ecodata_consulta TO usr_ecodata_consulta;
GRANT rol_ecodata_admin TO usr_ecodata_admin;

-- Conectividad a la base y acceso al esquema.
GRANT CONNECT ON DATABASE ecodata
TO rol_ecodata_app, rol_ecodata_consulta, rol_ecodata_admin;

GRANT USAGE ON SCHEMA public
TO rol_ecodata_app, rol_ecodata_consulta, rol_ecodata_admin;

-- El programa de carga necesita crear tablas temporales.
GRANT TEMPORARY ON DATABASE ecodata TO rol_ecodata_app;

-- Aplicacion: solamente las seis tablas necesarias para la carga.
GRANT SELECT, INSERT ON
    categoria,
    fuente,
    material,
    producto,
    producto_material,
    impacto_ambiental
TO rol_ecodata_app;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public
TO rol_ecodata_app;

-- Consulta: lectura en las nueve tablas.
GRANT SELECT ON ALL TABLES IN SCHEMA public
TO rol_ecodata_consulta;

-- Administracion operativa de datos.
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
TO rol_ecodata_admin;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public
TO rol_ecodata_admin;

GRANT CREATE ON SCHEMA public
TO rol_ecodata_admin;

-- Permisos predeterminados para futuras tablas creadas por lis.
ALTER DEFAULT PRIVILEGES FOR ROLE lis IN SCHEMA public
GRANT SELECT, INSERT ON TABLES TO rol_ecodata_app;

ALTER DEFAULT PRIVILEGES FOR ROLE lis IN SCHEMA public
GRANT SELECT ON TABLES TO rol_ecodata_consulta;

ALTER DEFAULT PRIVILEGES FOR ROLE lis IN SCHEMA public
GRANT ALL PRIVILEGES ON TABLES TO rol_ecodata_admin;

ALTER DEFAULT PRIVILEGES FOR ROLE lis IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO rol_ecodata_app;

ALTER DEFAULT PRIVILEGES FOR ROLE lis IN SCHEMA public
GRANT ALL PRIVILEGES ON SEQUENCES TO rol_ecodata_admin;
