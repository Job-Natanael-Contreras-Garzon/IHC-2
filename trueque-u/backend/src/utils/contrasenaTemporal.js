const crypto = require('crypto');

// Letras y números fáciles de leer (sin 0, O, 1, l, I).
const CARACTERES = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789';

// Crea una contraseña al azar de 8 caracteres.
function generarContrasenaTemporal() {
  let texto = '';
  for (let i = 0; i < 8; i++) {
    texto += CARACTERES[crypto.randomInt(0, CARACTERES.length)];
  }
  return texto;
}

module.exports = { generarContrasenaTemporal };
