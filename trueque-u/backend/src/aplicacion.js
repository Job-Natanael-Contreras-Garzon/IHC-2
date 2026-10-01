const express = require("express");
const cors = require("cors");
const rutas = require("./routes");
const {
  rutaNoEncontrada,
  manejarErrores,
} = require("./middleware/errores.middleware");

const aplicacion = express();

aplicacion.use(cors());
aplicacion.use(express.json());

aplicacion.use("/api", rutas);

aplicacion.use(rutaNoEncontrada);
aplicacion.use(manejarErrores);

module.exports = aplicacion;
