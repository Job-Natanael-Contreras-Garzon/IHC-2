const bcrypt = require('bcryptjs');

function cifrar(texto) {
  return bcrypt.hash(texto, 10);
}

function coincide(texto, hash) {
  return bcrypt.compare(texto, hash);
}

module.exports = { cifrar, coincide };
