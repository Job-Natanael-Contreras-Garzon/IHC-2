const Sequelize = require('sequelize');
module.exports = function(sequelize, DataTypes) {
  return sequelize.define('project_config', {
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
    endpoint_id: {
      type: DataTypes.TEXT,
      allowNull: false,
      unique: "project_config_endpoint_id_key"
    },
    trusted_origins: {
      type: DataTypes.JSONB,
      allowNull: false
    },
    social_providers: {
      type: DataTypes.JSONB,
      allowNull: false
    },
    email_provider: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    email_and_password: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    allow_localhost: {
      type: DataTypes.BOOLEAN,
      allowNull: false
    },
    plugin_configs: {
      type: DataTypes.JSONB,
      allowNull: true
    },
    webhook_config: {
      type: DataTypes.JSONB,
      allowNull: true
    }
  }, {
    sequelize,
    tableName: 'project_config',
    schema: 'neon_auth',
    timestamps: true,
    indexes: [
      {
        name: "project_config_endpoint_id_key",
        unique: true,
        fields: [
          { name: "endpoint_id" },
        ]
      },
      {
        name: "project_config_pkey",
        unique: true,
        fields: [
          { name: "id" },
        ]
      },
    ]
  });
};
