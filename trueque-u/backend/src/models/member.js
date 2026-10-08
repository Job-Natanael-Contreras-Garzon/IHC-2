const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('member', {
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
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'user',
        key: 'id'
      }
    },
    role: {
      type: DataTypes.TEXT,
      allowNull: false
    }
  }, {
    sequelize,
    tableName: 'member',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "member_organizationId_idx",
        fields: [
          { name: "organizationId" },
        ]
      },
      {
        name: "member_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
      {
        name: "member_userId_idx",
        fields: [
          { name: "userId" },
        ]
      },
    ]
  });
};
