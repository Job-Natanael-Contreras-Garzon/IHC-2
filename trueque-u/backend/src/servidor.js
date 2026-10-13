const aplicacion = require("./aplicacion");
const { puerto } = require("./configuration/entorno");
const { sequelize } = require("./database/sequelize");

async function iniciar() {
  // Se comprueba la base de datos antes de recibir peticiones.
  try {
    await sequelize.authenticate();
  } catch (error) {
    // El mensaje a veces llega vacío; por eso se muestran también el tipo y el código
    const detalle = error.original || error;
    console.error("No se pudo conectar a PostgreSQL:", error.message);
    console.error("Tipo:", detalle.name, "| Código:", detalle.code);
    // Si Node probó varias direcciones, cada intento fallido viene en "errors"
    for (const intento of detalle.errors || []) {
      console.error(" -", intento.code, `${intento.address}:${intento.port}`);
    }
    process.exit(1);
  }

  aplicacion.listen(puerto, () => {
    console.log(`Trueque U API escuchando en http://localhost:${puerto}`);
  });
}

iniciar();
