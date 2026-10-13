const { Router } = require("express");
const {
  putIntercambio,
  getIntercambios,
} = require("../controllers/intercambios.controlador");
const { exigirSesion } = require("../middleware/autenticacion.middleware");

const rutas = Router();

// Se monta en /api/publicaciones (index.js), antes que las rutas de publicaciones.

// Mis intercambios completados (perfil): como dueño o como quien reservó.
// Va antes de "/:id" (en publicaciones) para evitar colisión de ruta
rutas.get("/intercambiadas", exigirSesion, getIntercambios);

// Completar el intercambio: el dueño o quien reservó marcan la publicación como "intercambiado".
rutas.put("/:id/intercambiado", exigirSesion, putIntercambio);

module.exports = rutas;
