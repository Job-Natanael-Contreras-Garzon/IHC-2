const { Op } = require("sequelize");
const { models } = require("../database/sequelize");
const { estaReservado } = require("../utils/reglasObjeto");

// Condición del objeto: solo puede ser "nuevo" o "usado"
const ESTADOS = ["nuevo", "usado"];

// Datos que se agregan a cada publicación: quién la creó y quién la reservó
const INCLUIR_USUARIOS = [
  { model: models.usuarios, as: "autor", attributes: ["id", "nombre"] },
  {
    model: models.usuarios,
    as: "usuario_reserva",
    attributes: ["id", "nombre"],
  },
];

// Lee el :id de la URL. Devuelve null si no es un número válido
const leerId = (req) => {
  const id = Number(req.params.id);
  return Number.isInteger(id) && id > 0 ? id : null;
};

// Busca una publicación que sea de la persona con sesión.
// Si no existe o es de otra persona, responde el error y devuelve null
const buscarPublicacionPropia = async (req, res) => {
  const id = leerId(req);
  if (!id) {
    res.status(400).json({ error: "El id no es válido" });
    return null;
  }

  const publicacion = await models.publicaciones.findByPk(id, {
    include: INCLUIR_USUARIOS,
  });
  if (!publicacion) {
    res.status(404).json({ error: "Publicación no encontrada" });
    return null;
  }
  if (publicacion.id_usuario !== req.usuario.id) {
    res.status(403).json({ error: "Esta publicación no es tuya" });
    return null;
  }
  return publicacion;
};

// Si la publicación está reservada, el creador ya no puede tocarla
// (ni editar, ni eliminar, ni desactivar, ni descartar la reserva).
// Devuelve true y responde el error cuando hay que frenar la acción
const bloquearSiEstaReservada = (publicacion, res, accion) => {
  if (!estaReservado(publicacion)) return false;

  console.log(
    `[publicaciones] Bloqueado: no se puede ${accion} la publicación ${publicacion.id}, está reservada`,
  );
  res.status(409).json({
    error: `No puedes ${accion} una publicación que ya fue reservada`,
  });
  return true;
};

// GET /api/publicaciones
// Feed principal: todas las publicaciones menos las ocultas
const getPublicaciones = async (req, res) => {
  try {
    const publicaciones = await models.publicaciones.findAll({
      where: { estado_publicacion: { [Op.ne]: "oculto" } }, // Op.ne = distinto de
      include: INCLUIR_USUARIOS,
      order: [["id", "DESC"]], // las más nuevas primero
    });
    res.json(publicaciones);
  } catch (error) {
    console.error("Error al obtener el feed de publicaciones:", error);
    res.status(500).json({ error: "Error al obtener las publicaciones" });
  }
};

// GET /api/publicaciones/mias
// Solo las publicaciones de la persona con sesión, en cualquier estado
const getMisPublicaciones = async (req, res) => {
  try {
    const publicaciones = await models.publicaciones.findAll({
      where: { id_usuario: req.usuario.id },
      include: INCLUIR_USUARIOS,
      order: [["id", "DESC"]],
    });
    res.json(publicaciones);
  } catch (error) {
    console.error("Error al obtener mis publicaciones:", error);
    res.status(500).json({ error: "Error al obtener tus publicaciones" });
  }
};

// GET /api/publicaciones/:id
// Una publicación por su id. Si está oculta, solo la ve su creador
const getPublicacion = async (req, res) => {
  try {
    const id = leerId(req);
    if (!id) return res.status(400).json({ error: "El id no es válido" });

    const publicacion = await models.publicaciones.findByPk(id, {
      include: INCLUIR_USUARIOS,
    });

    const esOculta = publicacion && publicacion.estado_publicacion === "oculto";
    if (
      !publicacion ||
      (esOculta && publicacion.id_usuario !== req.usuario.id)
    ) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }
    res.json(publicacion);
  } catch (error) {
    console.error("Error al obtener la publicación:", error);
    res.status(500).json({ error: "Error al obtener la publicación" });
  }
};

// POST /api/publicaciones
// Crea una publicación de la persona con sesión (nace "disponible")
const postPublicacion = async (req, res) => {
  try {
    const { titulo, descripcion, estado } = req.body || {};

    // Se validan los datos que llegan
    if (typeof titulo !== "string" || titulo.trim().length < 2) {
      return res
        .status(400)
        .json({ error: "Escribe un título (mínimo 2 letras)" });
    }
    if (titulo.trim().length > 150) {
      return res
        .status(400)
        .json({ error: "El título es muy largo (máximo 150)" });
    }
    if (!ESTADOS.includes(estado)) {
      return res
        .status(400)
        .json({ error: "El estado debe ser nuevo o usado" });
    }

    const nueva = await models.publicaciones.create({
      id_usuario: req.usuario.id,
      titulo: titulo.trim(),
      descripcion: typeof descripcion === "string" ? descripcion.trim() : null,
      estado,
    });

    // Se vuelve a leer para devolverla con los datos del autor
    const publicacion = await models.publicaciones.findByPk(nueva.id, {
      include: INCLUIR_USUARIOS,
    });

    console.log(
      `[publicaciones] Creada: id ${nueva.id} (usuario ${req.usuario.id})`,
    );
    res.status(201).json(publicacion);
  } catch (error) {
    console.error("Error al crear publicación:", error);
    res.status(500).json({ error: "Error al crear la publicación" });
  }
};

// PUT /api/publicaciones/:id
// Edita título, descripción o condición. No se puede si está reservada
const putPublicacion = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;
    if (bloquearSiEstaReservada(publicacion, res, "editar")) return;

    const { titulo, descripcion, estado } = req.body || {};
    const cambios = {}; // aquí se van juntando solo los datos que llegaron

    if (titulo !== undefined) {
      if (
        typeof titulo !== "string" ||
        titulo.trim().length < 2 ||
        titulo.trim().length > 150
      ) {
        return res
          .status(400)
          .json({ error: "El título debe tener entre 2 y 150 letras" });
      }
      cambios.titulo = titulo.trim();
    }
    if (descripcion !== undefined) {
      cambios.descripcion =
        typeof descripcion === "string" ? descripcion.trim() : null;
    }
    if (estado !== undefined) {
      if (!ESTADOS.includes(estado)) {
        return res
          .status(400)
          .json({ error: "El estado debe ser nuevo o usado" });
      }
      cambios.estado = estado;
    }

    await publicacion.update(cambios);
    await publicacion.reload({ include: INCLUIR_USUARIOS });

    console.log(
      `[publicaciones] Actualizada: id ${publicacion.id} (usuario ${req.usuario.id})`,
    );
    res.json({ publicacion, mensaje: "Publicación actualizada correctamente" });
  } catch (error) {
    console.error("Error al actualizar publicación:", error);
    res.status(500).json({ error: "Error al actualizar la publicación" });
  }
};

// DELETE /api/publicaciones/:id
// Elimina para siempre una publicación propia. No se puede si está reservada
const deletePublicacion = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;
    if (bloquearSiEstaReservada(publicacion, res, "eliminar")) return;

    await publicacion.destroy();

    console.log(
      `[publicaciones] Eliminada: id ${publicacion.id} (usuario ${req.usuario.id})`,
    );
    res.json({ mensaje: "Publicación eliminada correctamente" });
  } catch (error) {
    console.error("Error al eliminar publicación:", error);
    res.status(500).json({ error: "Error al eliminar la publicación" });
  }
};

// PUT /api/publicaciones/:id/reservado
// Reserva una publicación. La puede reservar cualquier persona con sesión
// (o el creador, si acordó el trueque fuera de la app)
const putPublicacionReservado = async (req, res) => {
  try {
    const id = leerId(req);
    if (!id) return res.status(400).json({ error: "El id no es válido" });

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

    // Quien reserva: el id que llega en el body o, si no llega, la persona con sesión
    const idUsuarioReserva =
      req.body && req.body.id_usuario
        ? Number(req.body.id_usuario)
        : req.usuario.id;
    if (!Number.isInteger(idUsuarioReserva) || idUsuarioReserva <= 0) {
      return res
        .status(400)
        .json({ error: "El id del usuario que reserva no es válido" });
    }

    await publicacion.update({
      estado_publicacion: "reservado",
      id_usuario_reserva: idUsuarioReserva,
    });
    await publicacion.reload({ include: INCLUIR_USUARIOS });

    console.log(
      `[publicaciones] Reservada: id ${publicacion.id} por el usuario ${idUsuarioReserva}`,
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
// Vuelve a dejar la publicación disponible y borra la reserva.
// Si está reservada, solo puede hacerlo quien la reservó (el creador no).
// Si no está reservada (oculta o no disponible), el creador la reactiva
const putPublicacionDisponible = async (req, res) => {
  try {
    const id = leerId(req);
    if (!id) return res.status(400).json({ error: "El id no es válido" });

    const publicacion = await models.publicaciones.findByPk(id, {
      include: INCLUIR_USUARIOS,
    });
    if (!publicacion) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }

    const esDueno = publicacion.id_usuario === req.usuario.id;
    const esQuienReservo = publicacion.id_usuario_reserva === req.usuario.id;

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
      `[publicaciones] Disponible: id ${publicacion.id} (usuario ${req.usuario.id})`,
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

// PUT /api/publicaciones/:id/oculto
// El creador oculta su publicación del feed. No se puede si está reservada
const putPublicacionOculto = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;
    if (bloquearSiEstaReservada(publicacion, res, "ocultar")) return;

    await publicacion.update({
      estado_publicacion: "oculto",
      id_usuario_reserva: null,
    });
    await publicacion.reload({ include: INCLUIR_USUARIOS });

    console.log(
      `[publicaciones] Oculta: id ${publicacion.id} (usuario ${req.usuario.id})`,
    );
    res.json({ publicacion, mensaje: 'Publicación ahora está "oculto"' });
  } catch (error) {
    console.error("Error al ocultar publicación:", error);
    res
      .status(500)
      .json({ error: "Error al cambiar el estado de la publicación" });
  }
};

// PUT /api/publicaciones/:id/no-disponible
// El creador marca el objeto como no disponible (por ejemplo, ya se intercambió).
// No se puede si está reservada
const putPublicacionNoDisponible = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;
    if (
      bloquearSiEstaReservada(publicacion, res, "marcar como no disponible")
    ) {
      return;
    }

    await publicacion.update({
      estado_publicacion: "no disponible",
      id_usuario_reserva: null,
    });
    await publicacion.reload({ include: INCLUIR_USUARIOS });

    console.log(
      `[publicaciones] No disponible: id ${publicacion.id} (usuario ${req.usuario.id})`,
    );
    res.json({
      publicacion,
      mensaje: 'Publicación ahora está "no disponible"',
    });
  } catch (error) {
    console.error("Error al marcar publicación como no disponible:", error);
    res
      .status(500)
      .json({ error: "Error al cambiar el estado de la publicación" });
  }
};

module.exports = {
  getPublicaciones,
  getMisPublicaciones,
  getPublicacion,
  postPublicacion,
  putPublicacion,
  deletePublicacion,
  putPublicacionDisponible,
  putPublicacionOculto,
  putPublicacionReservado,
  putPublicacionNoDisponible,
};
