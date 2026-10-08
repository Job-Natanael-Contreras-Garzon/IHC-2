const {
  buscarUsuarioPorCorreo,
  buscarContrasenaHashPorId,
} = require("../models/usuarios.modelo");
const { crearSesion, cerrarSesion } = require("../models/sesiones.modelo");
const { coincide } = require("../services/contrasena.servicio");
const { firmarToken } = require("../services/token.servicio");
const { usuarioPublico } = require("../utils/serializadores");

// POST /api/sesiones  ->  inicio de sesión
async function postSesion(req, res) {
  const { correo, contrasena } = req.body || {};
  if (typeof correo !== "string" || typeof contrasena !== "string") {
    return res
      .status(400)
      .json({ error: "Correo y contraseña son obligatorios" });
  }

  const usuario = await buscarUsuarioPorCorreo(correo.trim().toLowerCase());
  if (!usuario || !(await coincide(contrasena, usuario.contrasena_hash))) {
    return res.status(401).json({ error: "Correo o contraseña incorrectos" });
  }

  const sesionId = await crearSesion(usuario.id);
  console.log(`[sesiones] Sesión iniciada: usuario ${usuario.id}`);
  res.json({
    token: firmarToken({ usuarioId: usuario.id, sesionId }),
    usuario: usuarioPublico(usuario),
  });
}

// GET /api/sesiones/actual  ->  quién tiene la sesión abierta (la app lo usa al recargar)
function getSesionActual(req, res) {
  res.json({ usuario: usuarioPublico(req.usuario) });
}

// DELETE /api/sesiones/actual  ->  cierre de sesión
async function deleteSesion(req, res) {
  await cerrarSesion(req.sesionId);
  console.log(`[sesiones] Sesión cerrada: usuario ${req.usuario.id}`);
  res.json({ ok: true });
}

module.exports = { postSesion, getSesionActual, deleteSesion };
