const { Router } = require("express");
const {
  postSesion,
  getSesionActual,
  deleteSesion,
} = require("../controllers/sesiones.controlador");
const { exigirSesion } = require("../middleware/autenticacion.middleware");

const rutas = Router();

rutas.post("/", postSesion); // pública: inicio de sesión
rutas.get("/actual", exigirSesion, getSesionActual); // privada
rutas.delete("/actual", exigirSesion, deleteSesion); // privada: cierre de sesión

module.exports = rutas;
