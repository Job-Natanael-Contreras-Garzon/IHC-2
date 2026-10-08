const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('verification', {
    id: {
      type: DataTypes.UUID,
      allowNull: false,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    identifier: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    value: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false
    }
  }, {
    sequelize,
    tableName: 'verification',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "verification_identifier_idx",
        fields: [
          { name: "identifier" },
        ]
      },
      {
        name: "verification_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
    ]
  });
};
