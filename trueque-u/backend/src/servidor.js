const aplicacion = require("./aplicacion");
const { puerto } = require("./configuration/entorno");
const { consultar } = require("./database/conexion");

async function iniciar() {
  // Se comprueba la base de datos antes de recibir peticiones.
  try {
    await consultar("SELECT 1");
  } catch (error) {
    console.error("No se pudo conectar a PostgreSQL:", error.message);
    process.exit(1);
  }

  aplicacion.listen(puerto, () => {
    console.log(`Trueque U API escuchando en http://localhost:${puerto}`);
  });
}

iniciar();
