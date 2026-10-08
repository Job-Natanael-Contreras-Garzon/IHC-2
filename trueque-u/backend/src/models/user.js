const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('user', {
    id: {
      type: DataTypes.UUID,
      allowNull: false,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    email: {
      type: DataTypes.TEXT,
      allowNull: false,
      unique: "user_email_key"
    },
    emailVerified: {
      type: DataTypes.BOOLEAN,
      allowNull: false
    },
    image: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    role: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    banned: {
      type: DataTypes.BOOLEAN,
      allowNull: true
    },
    banReason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    banExpires: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'user',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "user_email_key",
        unique: true,
        fields: [
          { name: "email" },
        ]
      },
      {
        name: "user_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
    ]
  });
};
