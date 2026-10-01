// Datos del usuario que se pueden enviar a la app (nunca el hash de la contraseña).
function usuarioPublico(usuario) {
  return { id: usuario.id, nombre: usuario.nombre, correo: usuario.correo };
}

module.exports = { usuarioPublico };
