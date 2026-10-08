const {
  buscarUsuarioPorCorreo,
  actualizarContrasenaUsuario,
} = require("../models/usuarios.modelo");
const { cifrar } = require("../services/contrasena.servicio");
const { enviarCorreo } = require("../services/correo.servicio");
const { esCorreoValido } = require("../utils/validaciones");
const { generarContrasenaTemporal } = require("../utils/contrasenaTemporal");

// POST /api/recuperaciones  ->  recuperar contraseña.
// Crea una contraseña nueva, la guarda y la envía al correo de la persona.
// Después puede entrar con ella y, si quiere, cambiarla (PUT /api/usuarios/contrasena).
async function postRecuperacion(req, res) {
  const { correo } = req.body || {};
  if (!esCorreoValido(correo)) {
    return res.status(400).json({ error: "Correo no válido" });
  }

  const usuario = await buscarUsuarioPorCorreo(correo.trim().toLowerCase());
  if (!usuario) {
    return res
      .status(404)
      .json({ error: "No existe una cuenta con ese correo" });
  }

  const contrasenaTemporal = generarContrasenaTemporal();
  await actualizarContrasenaUsuario(
    usuario.id,
    await cifrar(contrasenaTemporal),
  );

  try {
    await enviarCorreo(
      usuario.correo,
      "Tu nueva contraseña de Trueque U",
      `Hola ${usuario.nombre},\n\nTu nueva contraseña es: ${contrasenaTemporal}\n\n` +
        "Ya puedes iniciar sesión con ella. Si quieres, puedes cambiarla dentro de la aplicación.",
    );
  } catch (error) {
    console.error("No se pudo enviar el correo:", error.message);
    return res
      .status(502)
      .json({ error: "No se pudo enviar el correo. Intenta de nuevo." });
  }

  console.log(
    `[recuperaciones] Contraseña nueva enviada por correo: usuario ${usuario.id}`,
  );
  res.json({
    ok: true,
    mensaje: "Te enviamos una contraseña nueva a tu correo",
  });
}

module.exports = { postRecuperacion };
