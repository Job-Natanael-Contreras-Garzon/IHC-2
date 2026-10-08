const { models } = require("../database/sequelize");
const { cifrar } = require("../services/contrasena.servicio");
const { enviarCorreo } = require("../services/correo.servicio");
const { esCorreoValido } = require("../utils/validaciones");
const { generarContrasenaTemporal } = require("../utils/contrasenaTemporal");

// POST /api/recuperaciones
// Recupera la contraseña: crea una nueva, la guarda y la envía al correo.
// Después la persona entra con ella y, si quiere, la cambia en la app.
const postRecuperacion = async (req, res) => {
  try {
    const { correo } = req.body || {};
    if (!esCorreoValido(correo)) {
      return res.status(400).json({ error: "Correo no válido" });
    }

    // Se busca la cuenta con ese correo
    const usuario = await models.usuarios.findOne({
      where: { correo: correo.trim().toLowerCase() },
    });
    if (!usuario) {
      return res
        .status(404)
        .json({ error: "No existe una cuenta con ese correo" });
    }

    // Se genera la contraseña nueva y se guarda cifrada
    const contrasenaTemporal = generarContrasenaTemporal();
    await usuario.update({ contrasena_hash: await cifrar(contrasenaTemporal) });

    // Se envía por correo (si falla, la persona puede volver a intentarlo)
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
  } catch (error) {
    console.error("Error en la recuperación de contraseña:", error);
    res.status(500).json({ error: "Error al recuperar la contraseña" });
  }
};

module.exports = { postRecuperacion };
