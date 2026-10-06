const { Router } = require("express");
const {
  getPublicaciones,
  getMisPublicaciones,
  getPublicacion,
  postPublicacion,
  putPublicacion,
  deletePublicacion,
  putPublicacionDisponible,
  putPublicacionOculto,
  putPublicacionReservado,
  putPublicacionNoDisponible,
} = require("../controllers/publicaciones.controlador");
const { exigirSesion } = require("../middleware/autenticacion.middleware");

const rutas = Router();

// =========================================================================
// RUTAS DE CONSULTA Y GESTIÓN GENERAL DE PUBLICACIONES
// =========================================================================
// Feed general: obtiene todas las publicaciones visibles (disponibles y reservadas) en cuadrícula.
rutas.get("/", exigirSesion, getPublicaciones);

// Mis publicaciones: obtiene solo las publicaciones del usuario en sesión con su estado y reservas.
rutas.get("/mias", exigirSesion, getMisPublicaciones); // Va antes de "/:id" para evitar colisión de ruta

// Detalle de una publicación específica por su ID numérico.
rutas.get("/:id", exigirSesion, getPublicacion);

// Crear una nueva publicación (nace en estado "disponible").
rutas.post("/", exigirSesion, postPublicacion);

// Editar los datos básicos (título, descripción, condición nuevo/usado) de una publicación propia.
rutas.put("/:id", exigirSesion, putPublicacion);

// Eliminar definitivamente una publicación propia.
rutas.delete("/:id", exigirSesion, deletePublicacion);

// =========================================================================
// TRANSICIONES DE ESTADO (estado_publicacion) Y SISTEMA DE RESERVAS
// =========================================================================
// Volver a disponible / Descartar reserva:
// Libera la publicación (estado_publicacion = 'disponible') y limpia id_usuario_reserva = NULL.
// La puede invocar el usuario que reservó (para descartar) o el dueño (para liberar).
rutas.put("/:id/disponible", exigirSesion, putPublicacionDisponible);

// Ocultar publicación: el autor la oculta del feed general (solo él la verá en "Mis publicaciones").
rutas.put("/:id/oculto", exigirSesion, putPublicacionOculto);

// Reservar publicación:
// Cambia a estado_publicacion = 'reservado' y registra el ID del usuario en id_usuario_reserva.
// Puede ser llamada desde el feed por un usuario o por el propio dueño.
rutas.put("/:id/reservado", exigirSesion, putPublicacionReservado);

// Marcar como no disponible: el autor indica que el objeto ya no está disponible (trueque concluido).
rutas.put("/:id/no-disponible", exigirSesion, putPublicacionNoDisponible);

module.exports = rutas;
