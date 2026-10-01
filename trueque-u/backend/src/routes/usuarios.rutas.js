const { Router } = require("express");
const {
  postUsuario,
  putContrasena,
} = require("../controllers/usuarios.controlador");
const { exigirSesion } = require("../middleware/autenticacion.middleware");

const rutas = Router();

rutas.post("/", postUsuario); // pública: registro
rutas.put("/contrasena", exigirSesion, putContrasena); // privada: cambio de contraseña

module.exports = rutas;
