const { consultar } = require("../database/conexion");
const { duracionSesionDias } = require("../configuration/entorno");

// Crea una sesión abierta y devuelve su id.
async function crearSesion(usuarioId, ejecutar = consultar) {
  const expiraEn = new Date(
    Date.now() + duracionSesionDias * 24 * 60 * 60 * 1000,
  );
  const { rows } = await ejecutar(
    "INSERT INTO sesiones (usuario_id, expira_en) VALUES ($1, $2) RETURNING id",
    [usuarioId, expiraEn],
  );
  return rows[0].id;
}

// Devuelve el usuario dueño de la sesión, solo si sigue abierta y sin vencer.
async function buscarSesionActiva(sesionId, ejecutar = consultar) {
  const { rows } = await ejecutar(
    `SELECT u.id, u.nombre, u.correo
       FROM sesiones s
       JOIN usuarios u ON u.id = s.usuario_id
      WHERE s.id = $1
        AND s.cerrada_en IS NULL
        AND s.expira_en > NOW()`,
    [sesionId],
  );
  return rows[0] || null;
}

async function cerrarSesion(sesionId, ejecutar = consultar) {
  await ejecutar(
    "UPDATE sesiones SET cerrada_en = NOW() WHERE id = $1 AND cerrada_en IS NULL",
    [sesionId],
  );
}

module.exports = { crearSesion, buscarSesionActiva, cerrarSesion };
