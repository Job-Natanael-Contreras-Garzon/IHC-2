-- =====================================================================
-- Trueque U - Datos de prueba (3 usuarios)
-- =====================================================================
-- Ejecuta este script DESPUÉS de estructura.sql.
-- Las contraseñas están cifradas con bcrypt. Para iniciar sesión usa:
--
--   eudeniaflores@gmail.com    contraseña: eude1234
--   contrerasjob123@gmail.com  contraseña: contreras123
--   carlosmamani@ejemplo.com   contraseña: carlos1234
-- =====================================================================

INSERT INTO usuarios (nombre, correo, contrasena_hash) VALUES
    ('Eudenia Flores Veizaga', 'eudeniaflores@gmail.com',   '$2a$10$piJ7wa.ts95gkfCBdb5PION9e0mudZ/26fl7OeJY8aU/QrNt0tX0m'),
    ('Job Contreras',          'contrerasjob123@gmail.com', '$2a$10$Ys9ZyCk6aPALwak5vXmt0ejiIZtD8hheK3pYR2p1TU0bQVFL8hq8u'),
    ('Carlos Mamani',          'carlosmamani@ejemplo.com',  '$2a$10$rZVy8y2CGVTRBOpkCg9/UuqiVzXQcLjRLqkjzQT1gJJGwbqlkgwrC');
