// Ruta que no existe.
function rutaNoEncontrada(req, res) {
  res.status(404).json({ error: 'Ruta no encontrada' });
}

// Cualquier error no controlado (por ejemplo un JSON mal formado).
// eslint-disable-next-line no-unused-vars
function manejarErrores(error, req, res, next) {
  const estado = error.status || 500;
  if (estado >= 500) console.error(error);
  res.status(estado).json({
    error: estado >= 500 ? 'Error interno del servidor' : 'Solicitud no válida',
  });
}

module.exports = { rutaNoEncontrada, manejarErrores };
