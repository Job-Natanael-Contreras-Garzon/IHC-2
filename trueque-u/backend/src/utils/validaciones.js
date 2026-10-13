const PATRON_CORREO = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function esCorreoValido(correo) {
  return typeof correo === 'string' && PATRON_CORREO.test(correo.trim());
}

// Teléfono de Bolivia: exactamente 8 dígitos (sin espacios ni código de país)
const PATRON_TELEFONO = /^\d{8}$/;

function esTelefonoValido(telefono) {
  return typeof telefono === 'string' && PATRON_TELEFONO.test(telefono.trim());
}

// Devuelve un mensaje de error, o null si la contraseña es válida.
function validarContrasena(contrasena) {
  if (typeof contrasena !== 'string' || contrasena.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }
  return null;
}

module.exports = { esCorreoValido, esTelefonoValido, validarContrasena };
