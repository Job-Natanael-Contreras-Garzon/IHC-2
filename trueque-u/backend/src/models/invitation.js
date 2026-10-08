const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('invitation', {
    id: {
      type: DataTypes.UUID,
      allowNull: false,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    organizationId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'organization',
        key: 'id'
      }
    },
    email: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    role: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    status: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false
    },
    inviterId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'user',
        key: 'id'
      }
    }
  }, {
    sequelize,
    tableName: 'invitation',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "invitation_email_idx",
        fields: [
          { name: "email" },
        ]
      },
      {
        name: "invitation_organizationId_idx",
        fields: [
          { name: "organizationId" },
        ]
      },
      {
        name: "invitation_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
    ]
  });
};
