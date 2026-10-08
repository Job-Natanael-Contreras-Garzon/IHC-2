// Una publicación reservada no puede editarse, eliminarse, ocultarse ni marcarse como no disponible
function estaReservado(publicacion) {
  return publicacion.estado_publicacion === "reservado";
}

module.exports = { estaReservado };
