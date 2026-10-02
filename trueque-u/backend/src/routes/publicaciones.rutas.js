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

// Todas exigen sesión iniciada.
rutas.get("/", exigirSesion, getPublicaciones);
rutas.get("/mias", exigirSesion, getMisPublicaciones); // va antes de "/:id"
rutas.get("/:id", exigirSesion, getPublicacion);
rutas.post("/", exigirSesion, postPublicacion);
rutas.put("/:id", exigirSesion, putPublicacion);
rutas.delete("/:id", exigirSesion, deletePublicacion);

// Cambios de estado_publicacion
rutas.put("/:id/disponible", exigirSesion, putPublicacionDisponible);
rutas.put("/:id/oculto", exigirSesion, putPublicacionOculto);
rutas.put("/:id/reservado", exigirSesion, putPublicacionReservado);
rutas.put("/:id/no-disponible", exigirSesion, putPublicacionNoDisponible);

module.exports = rutas;
