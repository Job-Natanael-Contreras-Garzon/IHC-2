const PATRON_CORREO = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function esCorreoValido(correo) {
  return typeof correo === 'string' && PATRON_CORREO.test(correo.trim());
}

// Devuelve un mensaje de error, o null si la contraseña es válida.
function validarContrasena(contrasena) {
  if (typeof contrasena !== 'string' || contrasena.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }
  return null;
}

module.exports = { esCorreoValido, validarContrasena };
