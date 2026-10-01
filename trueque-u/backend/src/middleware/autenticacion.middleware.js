const { verificarToken } = require("../services/token.servicio");
const { buscarSesionActiva } = require("../models/sesiones.modelo");

// Exige una sesión válida: token correcto, sesión abierta y sin vencer.
async function exigirSesion(req, res, next) {
  const cabecera = req.headers.authorization || "";
  const token = cabecera.startsWith("Bearer ") ? cabecera.slice(7) : null;
  if (!token) return res.status(401).json({ error: "No has iniciado sesión" });

  let datos;
  try {
    datos = verificarToken(token);
  } catch (error) {
    return res.status(401).json({ error: "Sesión inválida o vencida" });
  }

  const usuario = await buscarSesionActiva(datos.jti);
  if (!usuario)
    return res.status(401).json({ error: "Sesión cerrada o vencida" });

  req.usuario = usuario;
  req.sesionId = datos.jti;
  next();
}

module.exports = { exigirSesion };
