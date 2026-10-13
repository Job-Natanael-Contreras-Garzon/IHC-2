// Una publicación reservada no puede editarse, eliminarse, ocultarse ni marcarse como no disponible
function estaReservado(publicacion) {
  return publicacion.estado_publicacion === "reservado";
}

// Una publicación intercambiada ya terminó: no puede reservarse, editarse,
// eliminarse, ocultarse ni completarse otra vez
function estaIntercambiado(publicacion) {
  return publicacion.estado_publicacion === "intercambiado";
}

// Regla para completar un intercambio.
// Solo se completa una publicación reservada, y solo lo hace el dueño o quien la reservó.
// Devuelve { permitido: true } o { permitido: false, codigo, motivo }
function puedeCompletarIntercambio(publicacion, idUsuario) {
  const esDueno = publicacion.id_usuario === idUsuario;
  const esQuienReservo = publicacion.id_usuario_reserva === idUsuario;

  if (!esDueno && !esQuienReservo) {
    return {
      permitido: false,
      codigo: 403,
      motivo: "Solo el dueño o quien reservó pueden completar el intercambio",
    };
  }
  if (estaIntercambiado(publicacion)) {
    return {
      permitido: false,
      codigo: 409,
      motivo: "Este intercambio ya fue completado",
    };
  }
  if (!estaReservado(publicacion)) {
    return {
      permitido: false,
      codigo: 409,
      motivo: "Solo se puede completar un intercambio de una publicación reservada. Primero debe reservarse",
    };
  }
  return { permitido: true };
}

module.exports = { estaReservado, estaIntercambiado, puedeCompletarIntercambio };
