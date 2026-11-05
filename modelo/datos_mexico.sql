
-- EcoData: carga inicial de catálogos y fuentes documentales.
-- Fuentes relacionadas con estudios de impacto ambiental en México.
-- No se insertan mediciones ambientales sin verificar sus valores y unidades.

BEGIN;

INSERT INTO categoria (nombre, descripcion)
VALUES
    ('Envases para bebidas',
     'Envases utilizados para contener bebidas.'),
    ('Productos reutilizables',
     'Productos diseñados para utilizarse varias veces.'),
    ('Productos desechables',
     'Productos destinados a un uso limitado antes de su descarte.');

INSERT INTO pais (nombre)
VALUES ('México');

INSERT INTO material (nombre, descripcion, tipo, reciclable)
VALUES
    ('PET',
     'Polietileno tereftalato utilizado en envases.',
     'Plástico',
     TRUE),
    ('Vidrio',
     'Material utilizado en envases de bebidas.',
     'Vidrio',
     TRUE),
    ('Aluminio',
     'Metal utilizado en envases de bebidas.',
     'Metal',
     TRUE),
    ('Acero inoxidable',
     'Aleación metálica utilizada en productos reutilizables.',
     'Metal',
     TRUE);

INSERT INTO fuente (nombre, tipo, url, fecha_consulta)
VALUES
    (
      'INECC - Estudio de ACV de envases de PET posconsumo en México',
      'Estudio institucional',
      'https://www.gob.mx/inecc/documentos/estudio-de-analisis-de-ciclo-de-vida-acv-de-envases-de-bebidas-de-polietilen-tereftalato-pet-en-la-fase-de-pos-consumo',
      CURRENT_DATE
    ),
    (
      'UANL - Sustentabilidad de materiales para envasado de refrescos',
      'Artículo científico',
      'https://doi.org/10.29105/ingenierias27.96-947',
      CURRENT_DATE
    ),
    (
      'UNAM - Análisis de ciclo de vida de botellas PET recolectadas en Ecatepec',
      'Tesis de maestría',
      'https://repositorio.unam.mx/contenidos/348001',
      CURRENT_DATE
    );

COMMIT;
