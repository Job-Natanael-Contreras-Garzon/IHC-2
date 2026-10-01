const { Router } = require("express");
const {
  postRecuperacion,
} = require("../controllers/recuperaciones.controlador");

const rutas = Router();

rutas.post("/", postRecuperacion); // pública: pedir la contraseña nueva por correo

module.exports = rutas;
