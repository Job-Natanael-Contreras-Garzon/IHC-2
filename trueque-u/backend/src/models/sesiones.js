const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('sesiones', {
    id: {
      type: DataTypes.UUID,
      allowNull: false,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    usuario_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'usuarios',
        key: 'id'
      }
    },
    creada_en: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: Sequelize.Sequelize.fn('now')
    },
    expira_en: {
      type: DataTypes.DATE,
      allowNull: false
    },
    cerrada_en: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'sesiones',
    schema: 'public',
    timestamps: false,
    indexes: [
      {
        name: "sesiones_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
      {
        name: "sesiones_usuario_idx",
        fields: [
          { name: "usuario_id" },
        ]
      },
    ]
  });
};
