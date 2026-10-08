const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('session', {
    id: {
      type: DataTypes.UUID,
      allowNull: false,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false
    },
    token: {
      type: DataTypes.TEXT,
      allowNull: false,
      unique: "session_token_key"
    },
    ipAddress: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    userAgent: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'user',
        key: 'id'
      }
    },
    impersonatedBy: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    activeOrganizationId: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'session',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "session_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
      {
        name: "session_token_key",
        unique: true,
        fields: [
          { name: "token" },
        ]
      },
      {
        name: "session_userId_idx",
        fields: [
          { name: "userId" },
        ]
      },
    ]
  });
};
