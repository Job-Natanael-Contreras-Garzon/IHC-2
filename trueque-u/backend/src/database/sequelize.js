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

// Registro del modelo "usuario" para permitir relaciones/joins con las publicaciones.
const Usuario = sequelize.define(
  "usuario",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    nombre: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    correo: {
      type: DataTypes.STRING(150),
      allowNull: false,
    },
  },
  {
    tableName: "usuarios",
    timestamps: false,
  },
);

// Registro del modelo de publicaciones.
const Publicacion = require("../models/publicaciones.modelo")(sequelize, DataTypes);

// ASOCIACIONES:
// 1. Una publicación pertenece a su creador/autor (id_usuario).
Publicacion.belongsTo(Usuario, {
  as: "autor",
  foreignKey: "id_usuario",
});

// 2. Una publicación puede estar reservada por un usuario (id_usuario_reserva).
Publicacion.belongsTo(Usuario, {
  as: "usuario_reserva",
  foreignKey: "id_usuario_reserva",
});

// Exporta sequelize y los modelos mapeados (models.publicacion, models.usuario).
module.exports = { sequelize, models: sequelize.models };

