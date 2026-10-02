-- =====================================================================
-- Trueque U - Estructura de la base de datos (PostgreSQL)
-- =====================================================================
-- Antes de ejecutar este script:
--   1. Crea la base:   CREATE DATABASE trueque_u;
--   2. Conéctate a ella (en pgAdmin: clic derecho en trueque_u > Query Tool).
-- Luego ejecuta este archivo completo, y después datos.sql.
-- =====================================================================

-- Si quieres empezar de cero, descomenta estas líneas:
-- DROP TABLE IF EXISTS sesiones;
-- DROP TABLE IF EXISTS usuarios;

-- Personas registradas en la aplicación.
CREATE TABLE usuarios (
    id               INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    correo           VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash  VARCHAR(100) NOT NULL,          -- contraseña cifrada con bcrypt, nunca en texto plano
    creado_en        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT usuarios_correo_en_minusculas CHECK (correo = LOWER(correo))
);

-- Cada inicio de sesión (o registro) crea una fila. Cerrar sesión la marca como cerrada.
CREATE TABLE sesiones (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id  INTEGER     NOT NULL REFERENCES usuarios (id) ON DELETE CASCADE,
    creada_en   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expira_en   TIMESTAMPTZ NOT NULL,
    cerrada_en  TIMESTAMPTZ                          -- NULL mientras la sesión siga abierta
);

CREATE INDEX sesiones_usuario_idx ON sesiones (usuario_id);

-- Objetos o materiales que publica una persona para intercambiar.
-- Relación uno a muchos: un usuario tiene muchas publicaciones y cada publicación es de un solo usuario.
CREATE TABLE publicaciones (
    id                   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario           INTEGER      NOT NULL REFERENCES usuarios (id) ON DELETE CASCADE,
    titulo               VARCHAR(150) NOT NULL,
    descripcion          TEXT,
    estado               VARCHAR(10)  NOT NULL CHECK (estado IN ('nuevo', 'usado')),
    estado_publicacion   VARCHAR(15)  NOT NULL DEFAULT 'disponible'
                         CHECK (estado_publicacion IN ('oculto', 'disponible', 'reservado', 'no disponible'))
);

CREATE INDEX publicaciones_usuario_idx ON publicaciones (id_usuario);
