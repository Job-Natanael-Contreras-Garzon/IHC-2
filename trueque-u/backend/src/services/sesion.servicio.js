const { models } = require("../database/sequelize");
const { duracionSesionDias } = require("../configuration/entorno");

// Crea una sesión abierta para el usuario y devuelve su id.
// "transaccion" es opcional: se usa cuando se crea junto con otra cosa (el registro).
const crearSesion = async (usuarioId, transaccion) => {
  // La sesión vence a los 7 días (duracionSesionDias)
  const venceEn = new Date(
    Date.now() + duracionSesionDias * 24 * 60 * 60 * 1000,
  );
  const sesion = await models.sesiones.create(
    { usuario_id: usuarioId, expira_en: venceEn },
    { transaction: transaccion },
  );
  return sesion.id;
};

module.exports = { crearSesion };
