const nodemailer = require("nodemailer");
const { correo } = require("../configuration/entorno");

// Envía un correo de texto simple por Gmail.
// Si no hay datos de Gmail en el .env, solo muestra el mensaje en la consola del backend.
async function enviarCorreo(destino, asunto, texto) {
  if (!correo.usuario || !correo.clave) {
    console.log(
      `[correo no configurado] Falta en el .env: ${!correo.usuario ? "CORREO_USUARIO " : ""}${!correo.clave ? "CORREO_CLAVE" : ""}`,
    );
    console.log(`Para: ${destino}\n${asunto}\n${texto}`);
    return;
  }

  const transporte = nodemailer.createTransport({
    service: "gmail",
    auth: { user: correo.usuario, pass: correo.clave },
  });

  await transporte.sendMail({
    from: `"Trueque U" <${correo.usuario}>`,
    to: destino,
    subject: asunto,
    text: texto,
  });
}

module.exports = { enviarCorreo };
