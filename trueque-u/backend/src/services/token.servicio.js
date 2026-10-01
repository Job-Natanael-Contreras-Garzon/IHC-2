const jwt = require("jsonwebtoken");
const { jwtSecreto, duracionSesionDias } = require("../configuration/entorno");

// El token lleva el id de la sesión (jti): así se puede cerrar desde el servidor.
function firmarToken({ usuarioId, sesionId }) {
  return jwt.sign({ sub: String(usuarioId) }, jwtSecreto, {
    expiresIn: `${duracionSesionDias}d`,
    jwtid: sesionId,
  });
}

// Lanza un error si el token es inválido o venció.
function verificarToken(token) {
  return jwt.verify(token, jwtSecreto);
}

module.exports = { firmarToken, verificarToken };
