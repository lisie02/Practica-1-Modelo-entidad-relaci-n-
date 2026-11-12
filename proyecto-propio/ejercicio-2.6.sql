-- ============================================================
-- EcoData | Ejercicio 2.6
-- Comparación de acciones referenciales ON DELETE:
-- CASCADE y RESTRICT en la relación fuente -> impacto_ambiental.
--
-- IMPORTANTE:
-- Este guion está documentado para ejecutarse con psql.
-- Las pruebas deben realizarse en copias de ecodata, nunca en
-- la base original.
--
-- Copias utilizadas:
--   ecodata_cascade
--   ecodata_restrict
--
-- La fuente UANL corresponde a id_fuente = 2 en los datos cargados.
-- Verificar el ID con SELECT antes de ejecutar DELETE si se recrean
-- las bases o se modifica el orden de inserción de fuentes.
-- ============================================================


-- ============================================================
-- 1. PRUEBA ON DELETE CASCADE
-- Base: ecodata_cascade
-- Resultado observado: 3 impactos antes; 0 después.
-- ============================================================

\c ecodata_cascade

-- Configurar la llave foránea con CASCADE.
ALTER TABLE impacto_ambiental
DROP CONSTRAINT impacto_ambiental_id_fuente_fkey;

ALTER TABLE impacto_ambiental
ADD CONSTRAINT impacto_ambiental_id_fuente_fkey
FOREIGN KEY (id_fuente)
REFERENCES fuente(id_fuente)
ON DELETE CASCADE;

-- Comprobar los impactos relacionados antes del borrado.
SELECT COUNT(*) AS impactos_antes
FROM impacto_ambiental
WHERE id_fuente = 2;

-- Eliminar la fuente de prueba.
-- CASCADE elimina automáticamente los impactos que la referencian.
DELETE FROM fuente
WHERE id_fuente = 2;

-- Comprobar que ya no quedan impactos asociados.
SELECT COUNT(*) AS impactos_despues
FROM impacto_ambiental
WHERE id_fuente = 2;


-- ============================================================
-- 2. PRUEBA ON DELETE RESTRICT
-- Base: ecodata_restrict
-- Resultado observado: el DELETE es rechazado y permanecen
-- los 3 impactos asociados.
-- ============================================================

\c ecodata_restrict

-- Configurar la llave foránea con RESTRICT.
ALTER TABLE impacto_ambiental
DROP CONSTRAINT impacto_ambiental_id_fuente_fkey;

ALTER TABLE impacto_ambiental
ADD CONSTRAINT impacto_ambiental_id_fuente_fkey
FOREIGN KEY (id_fuente)
REFERENCES fuente(id_fuente)
ON DELETE RESTRICT;

-- Comprobar los impactos relacionados antes del intento.
SELECT COUNT(*) AS impactos_antes
FROM impacto_ambiental
WHERE id_fuente = 2;

-- Intento de eliminación:
-- PostgreSQL debe rechazar esta instrucción porque existen
-- registros de impacto_ambiental que referencian la fuente.
DELETE FROM fuente
WHERE id_fuente = 2;

-- Ejecutar esta consulta después del error anterior.
-- Debe devolver 3, porque los registros se conservan.
SELECT COUNT(*) AS impactos_despues
FROM impacto_ambiental
WHERE id_fuente = 2;


-- ============================================================
-- 3. CONSULTA DE VERIFICACIÓN DE LA RELACIÓN
-- Puede ejecutarse en ecodata_restrict para visualizar los datos
-- que permanecen asociados a la fuente.
-- ============================================================

SELECT
    f.id_fuente,
    f.nombre AS fuente,
    COUNT(ia.id_fuente) AS total_impactos
FROM fuente AS f
LEFT JOIN impacto_ambiental AS ia
    ON ia.id_fuente = f.id_fuente
WHERE f.id_fuente = 2
GROUP BY f.id_fuente, f.nombre;

-- Fin del ejercicio 2.6.
