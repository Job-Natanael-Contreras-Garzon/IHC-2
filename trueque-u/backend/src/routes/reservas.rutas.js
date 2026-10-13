const { Router } = require("express");
const {
  putReserva,
  putReservaDescartada,
} = require("../controllers/reservas.controlador");
const { exigirSesion } = require("../middleware/autenticacion.middleware");

const rutas = Router();

// Todo lo de reservas vive aquí. Se monta en /api/publicaciones (index.js),
// así las URLs son las mismas de siempre y el front no cambia.

// Reservar: cualquier usuario con sesión reserva una publicación "disponible".
// Cambia estado_publicacion a "reservado" y guarda quién reservó en id_usuario_reserva.
rutas.put("/:id/reservado", exigirSesion, putReserva);

// Descartar reserva (volver a disponible):
// Pone estado_publicacion = "disponible" y id_usuario_reserva = NULL.
// Si está reservada, solo quien la reservó puede hacerlo (el dueño no).
// Si está oculta o no disponible, el dueño la reactiva.
rutas.put("/:id/disponible", exigirSesion, putReservaDescartada);

module.exports = rutas;
