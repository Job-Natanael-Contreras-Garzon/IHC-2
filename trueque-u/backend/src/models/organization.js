const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('organization', {
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
    slug: {
      type: DataTypes.TEXT,
      allowNull: false,
      unique: "organization_slug_key"
    },
    logo: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    metadata: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'organization',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "organization_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
      {
        name: "organization_slug_key",
        unique: true,
        fields: [
          { name: "slug" },
        ]
      },
      {
        name: "organization_slug_uidx",
        unique: true,
        fields: [
          { name: "slug" },
        ]
      },
    ]
  });
};
