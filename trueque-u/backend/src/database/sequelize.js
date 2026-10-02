const { Sequelize, DataTypes } = require("sequelize");
const { baseDeDatos } = require("../configuration/entorno");

// Crea la conexión de Sequelize con los mismos datos del .env que usa el resto del backend.
function crearConexion() {
  const { connectionString, host, port, database, user, password } = baseDeDatos;

  // Base en línea (Neon): se usa la cadena de conexión.
  // Si la cadena trae sslmode (Neon la trae), se conecta con SSL.
  if (connectionString) {
    const sinParametros = connectionString.replace(/\?.*$/, "");
    const usaSsl = connectionString.includes("sslmode=");
    return new Sequelize(sinParametros, {
      dialect: "postgres",
      logging: false,
      dialectOptions: usaSsl ? { ssl: true } : {},
    });
  }

  // PostgreSQL instalado en tu computador.
  return new Sequelize(database, user, password, {
    host,
    port,
    dialect: "postgres",
    logging: false,
  });
}

const sequelize = crearConexion();

// Aquí se registra cada modelo. Para agregar uno nuevo: una línea más.
require("../models/publicaciones.modelo")(sequelize, DataTypes);

// models.publicacion, models.<otro modelo>...
module.exports = { sequelize, models: sequelize.models };
