const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('jwks', {
    id: {
      type: DataTypes.UUID,
      allowNull: false,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    publicKey: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    privateKey: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'jwks',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "jwks_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
    ]
  });
};
