const aplicacion = require("./aplicacion");
const { puerto } = require("./configuration/entorno");
const { sequelize } = require("./database/sequelize");

async function iniciar() {
  // Se comprueba la base de datos antes de recibir peticiones.
  try {
    await sequelize.authenticate();
  } catch (error) {
    console.error("No se pudo conectar a PostgreSQL:", error.message);
    process.exit(1);
  }

  aplicacion.listen(puerto, () => {
    console.log(`Trueque U API escuchando en http://localhost:${puerto}`);
  });
}

iniciar();
