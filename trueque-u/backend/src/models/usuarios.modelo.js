const { consultar } = require("../database/conexion");

async function buscarUsuarioPorCorreo(correo, ejecutar = consultar) {
  const { rows } = await ejecutar(
    "SELECT id, nombre, correo, contrasena_hash FROM usuarios WHERE correo = $1",
    [correo],
  );
  return rows[0] || null;
}

async function crearUsuario(
  { nombre, correo, contrasenaHash },
  ejecutar = consultar,
) {
  const { rows } = await ejecutar(
    `INSERT INTO usuarios (nombre, correo, contrasena_hash)
     VALUES ($1, $2, $3)
     RETURNING id, nombre, correo`,
    [nombre, correo, contrasenaHash],
  );
  return rows[0];
}

async function actualizarContrasenaUsuario(
  usuarioId,
  contrasenaHash,
  ejecutar = consultar,
) {
  await ejecutar("UPDATE usuarios SET contrasena_hash = $1 WHERE id = $2", [
    contrasenaHash,
    usuarioId,
  ]);
}

async function buscarContrasenaHashPorId(usuarioId, ejecutar = consultar) {
  const { rows } = await ejecutar(
    "SELECT contrasena_hash FROM usuarios WHERE id = $1",
    [usuarioId],
  );
  return rows[0] ? rows[0].contrasena_hash : null;
}

module.exports = {
  buscarUsuarioPorCorreo,
  crearUsuario,
  actualizarContrasenaUsuario,
  buscarContrasenaHashPorId,
};
