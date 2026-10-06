// Modelo de la tabla "publicaciones" (ver base_de_datos/estructura.sql).
// Un usuario tiene muchas publicaciones; cada publicación es de un solo usuario.
module.exports = function (sequelize, DataTypes) {
  return sequelize.define(
    "publicacion",
    {
      id: {
        autoIncrement: true,
        type: DataTypes.INTEGER,
        allowNull: false,
        primaryKey: true,
      },
      id_usuario: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: "usuarios", key: "id" },
      },
      titulo: {
        type: DataTypes.STRING(150),
        allowNull: false,
      },
      descripcion: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      // Cómo está el objeto: nuevo o usado.
      estado: {
        type: DataTypes.STRING(10),
        allowNull: false,
      },
      // Cómo está la publicación: oculto, disponible, reservado o no disponible.
      estado_publicacion: {
        type: DataTypes.STRING(15),
        allowNull: false,
        defaultValue: "disponible",
      },
      // ID del usuario que reservó la publicación (NULL si no tiene reserva activa).
      id_usuario_reserva: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: { model: "usuarios", key: "id" },
      },
    },
    {
      sequelize,
      tableName: "publicaciones",
      timestamps: false,
    },
  );
};
