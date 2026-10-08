// Un objeto reservado no puede editarse ni eliminarse
function estaReservado(objeto) {
  return objeto.estado === "reservado";
}

module.exports = { estaReservado };
