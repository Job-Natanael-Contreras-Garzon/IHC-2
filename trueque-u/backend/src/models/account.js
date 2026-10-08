const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('account', {
    id: {
      type: DataTypes.UUID,
      allowNull: false,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    accountId: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    providerId: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'user',
        key: 'id'
      }
    },
    accessToken: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    refreshToken: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    idToken: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    accessTokenExpiresAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    refreshTokenExpiresAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    scope: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    password: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'account',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "account_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
      {
        name: "account_userId_idx",
        fields: [
          { name: "userId" },
        ]
      },
    ]
  });
};
