const { models } = require("../database/sequelize");
const { estaIntercambiado } = require("../utils/reglasObjeto");

// Datos que se agregan a cada publicación: quién la creó y quién la reservó
const INCLUIR_USUARIOS = [
  { model: models.usuarios, as: "autor", attributes: ["id", "nombre"] },
  {
    model: models.usuarios,
    as: "usuario_reserva",
    attributes: ["id", "nombre"],
  },
];

// PUT /api/publicaciones/:id/reservado
// Reserva una publicación disponible. La puede reservar cualquier persona con sesión, menos su dueño.
// Quien reserva siempre es la persona con sesión (no se acepta otro id en el body)
const putReserva = async (req, res) => {
  try {
    const idUsuario = req.usuario.id;

    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "El id no es válido" });
    }

    const publicacion = await models.publicaciones.findByPk(id, {
      include: INCLUIR_USUARIOS,
    });
    if (!publicacion) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }

    // No se puede reservar dos veces
    if (publicacion.estado_publicacion === "reservado") {
      return res
        .status(409)
        .json({ error: "La publicación ya se encuentra reservada" });
    }

    // El dueño no puede reservar su propia publicación
    if (publicacion.id_usuario === idUsuario) {
      return res
        .status(403)
        .json({ error: "No puedes reservar tu propia publicación" });
    }

    // Un intercambio completado no se puede reservar
    if (estaIntercambiado(publicacion)) {
      return res
        .status(409)
        .json({ error: "La publicación ya fue intercambiada" });
    }

    // Solo se reserva lo que está disponible (no lo oculto ni lo no disponible)
    if (publicacion.estado_publicacion !== "disponible") {
      return res
        .status(409)
        .json({ error: "Solo se puede reservar una publicación disponible" });
    }

    await publicacion.update({
      estado_publicacion: "reservado",
      id_usuario_reserva: idUsuario,
    });
    await publicacion.reload({ include: INCLUIR_USUARIOS });

    console.log(
      `[reservas] Reservada: id ${publicacion.id} por el usuario ${idUsuario}`,
    );
    res.json({
      publicacion,
      mensaje: "Publicación reservada correctamente",
    });
  } catch (error) {
    console.error("Error al reservar publicación:", error);
    res.status(500).json({ error: "Error al reservar la publicación" });
  }
};

// PUT /api/publicaciones/:id/disponible
// Descarta la reserva: deja la publicación disponible y borra la reserva.
// Si está reservada, solo puede hacerlo quien la reservó (el creador no).
// Si no está reservada (oculta o no disponible), el creador la reactiva (por eso la ruta se llama /disponible)
const putReservaDescartada = async (req, res) => {
  try {
    const idUsuario = req.usuario.id;

    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "El id no es válido" });
    }

    const publicacion = await models.publicaciones.findByPk(id, {
      include: INCLUIR_USUARIOS,
    });
    if (!publicacion) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }

    // Un intercambio completado no se puede deshacer
    if (estaIntercambiado(publicacion)) {
      return res
        .status(409)
        .json({ error: "El intercambio ya fue completado, no se puede cambiar" });
    }

    const esDueno = publicacion.id_usuario === idUsuario;
    const esQuienReservo = publicacion.id_usuario_reserva === idUsuario;

    // Reservada: el creador no puede descartar la reserva de otra persona
    if (publicacion.estado_publicacion === "reservado" && !esQuienReservo) {
      return res.status(403).json({
        error:
          "La publicación está reservada. Solo quien la reservó puede descartar la reserva",
      });
    }

    // Solo el creador o quien reservó pueden hacer este cambio
    if (!esDueno && !esQuienReservo) {
      return res.status(403).json({
        error:
          "No tienes permiso para liberar o descartar la reserva de esta publicación",
      });
    }

    await publicacion.update({
      estado_publicacion: "disponible",
      id_usuario_reserva: null, // ya no hay nadie con reserva
    });
    await publicacion.reload({ include: INCLUIR_USUARIOS });

    console.log(
      `[reservas] Disponible: id ${publicacion.id} (usuario ${idUsuario})`,
    );
    res.json({
      publicacion,
      mensaje: "Publicación ahora disponible para intercambio",
    });
  } catch (error) {
    console.error("Error al poner publicación en disponible:", error);
    res.status(500).json({ error: "Error al actualizar la publicación" });
  }
};

module.exports = {
  putReserva,
  putReservaDescartada,
};
