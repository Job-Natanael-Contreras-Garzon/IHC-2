const { Pool } = require("pg");
const { baseDeDatos } = require("../configuration/entorno");

const pool = new Pool(baseDeDatos);

// Ejecuta una consulta SQL con parámetros ($1, $2, ...).
function consultar(texto, parametros = []) {
  return pool.query(texto, parametros);
}

// Agrupa varias consultas: si una falla, se deshacen todas.
async function transaccion(trabajo) {
  const cliente = await pool.connect();
  try {
    await cliente.query("BEGIN");
    const resultado = await trabajo((texto, parametros = []) =>
      cliente.query(texto, parametros),
    );
    await cliente.query("COMMIT");
    return resultado;
  } catch (error) {
    await cliente.query("ROLLBACK");
    throw error;
  } finally {
    cliente.release();
  }
}

module.exports = { consultar, transaccion };
