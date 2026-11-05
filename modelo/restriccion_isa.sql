-- Restricción de disyunción de la jerarquía ISA:
-- un producto no puede ser reutilizable y desechable al mismo tiempo.

CREATE OR REPLACE FUNCTION verificar_disyuncion_producto()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'producto_reutilizable' THEN
        IF EXISTS (
            SELECT 1
            FROM producto_desechable
            WHERE id_producto = NEW.id_producto
        ) THEN
            RAISE EXCEPTION
                'El producto % ya está registrado como desechable',
                NEW.id_producto;
        END IF;
    ELSE
        IF EXISTS (
            SELECT 1
            FROM producto_reutilizable
            WHERE id_producto = NEW.id_producto
        ) THEN
            RAISE EXCEPTION
                'El producto % ya está registrado como reutilizable',
                NEW.id_producto;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_disyuncion_reutilizable
BEFORE INSERT OR UPDATE OF id_producto
ON producto_reutilizable
FOR EACH ROW
EXECUTE FUNCTION verificar_disyuncion_producto();

CREATE TRIGGER trg_disyuncion_desechable
BEFORE INSERT OR UPDATE OF id_producto
ON producto_desechable
FOR EACH ROW
EXECUTE FUNCTION verificar_disyuncion_producto();