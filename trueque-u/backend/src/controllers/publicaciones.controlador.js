const { Op } = require("sequelize");
const { models } = require("../database/sequelize");

// Estados válidos para la condición física del objeto
const ESTADOS = ["nuevo", "usado"];

// Estados válidos para el ciclo de vida de la publicación
const ESTADOS_PUBLICACION_VALIDOS = [
  "disponible",
  "reservado",
  "oculto",
  "no disponible",
];

// Opciones estándar para incluir información de autor y de reserva en las consultas
const INCLUIR_USUARIOS = [
  {
    model: models.usuario,
    as: "autor",
    attributes: ["id", "nombre"],
  },
  {
    model: models.usuario,
    as: "usuario_reserva",
    attributes: ["id", "nombre"],
  },
];

// Lee y valida el parámetro numérico :id de la URL.
function leerId(req) {
  const id = Number(req.params.id);
  return Number.isInteger(id) && id > 0 ? id : null;
}

// Busca una publicación que pertenezca exclusivamente al usuario en sesión.
// Se usa para acciones que solo el creador original puede realizar (editar, borrar, ocultar).
async function buscarPublicacionPropia(req, res) {
  const id = leerId(req);
  if (!id) {
    res.status(400).json({ error: "El id no es válido" });
    return null;
  }
  const publicacion = await models.publicacion.findByPk(id, {
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
}

/**
 * GET /api/publicaciones (FEED PRINCIPAL)
 * -------------------------------------------------------------
 * PROPÓSITO:
 * Obtener el listado general de publicaciones para la pantalla del feed (vista en cuadrícula).
 * Muestra tanto las publicaciones disponibles como las reservadas (excluyendo únicamente las "ocultas").
 * 
 * RETORNA:
 * Cada publicación incluye los datos de su creador ('autor') y, en caso de estar reservada,
 * los datos de la persona que la apartó ('usuario_reserva'). Esto permite al frontend decidir
 * si renderiza el botón "Reservar", "Descartar" (si fue reservada por el usuario en sesión),
 * o un mensaje indicando que fue reservada por otro usuario.
 */
const getPublicaciones = async (req, res) => {
  try {
    const publicaciones = await models.publicacion.findAll({
      // Se muestran todas las publicaciones visibles al público (no ocultas)
      where: {
        estado_publicacion: { [Op.ne]: "oculto" },
      },
      include: INCLUIR_USUARIOS,
      order: [["id", "DESC"]],
    });
    res.json(publicaciones);
  } catch (error) {
    console.error("Error al obtener el feed de publicaciones:", error);
    res.status(500).json({ error: "Error al obtener las publicaciones" });
  }
};

/**
 * GET /api/publicaciones/mias (MIS PUBLICACIONES)
 * -------------------------------------------------------------
 * PROPÓSITO:
 * Obtener todas las publicaciones creadas por la persona con sesión activa,
 * sin importar su estado (disponible, reservado, oculto, no disponible).
 * 
 * RETORNA:
 * Incluye 'usuario_reserva' para que el dueño sepa qué usuario le ha reservado
 * el objeto y pueda gestionar su estado (por ejemplo, descartar la reserva o cambiar de modo).
 */
const getMisPublicaciones = async (req, res) => {
  try {
    const publicaciones = await models.publicacion.findAll({
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

/**
 * GET /api/publicaciones/:id
 * -------------------------------------------------------------
 * Obtiene el detalle de una publicación individual por ID.
 * Si está oculta, solo su dueño puede consultarla.
 */
const getPublicacion = async (req, res) => {
  try {
    const id = leerId(req);
    if (!id) return res.status(400).json({ error: "El id no es válido" });

    const publicacion = await models.publicacion.findByPk(id, {
      include: INCLUIR_USUARIOS,
    });
    const esOculta = publicacion && publicacion.estado_publicacion === "oculto";
    if (!publicacion || (esOculta && publicacion.id_usuario !== req.usuario.id)) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }
    res.json(publicacion);
  } catch (error) {
    console.error("Error al obtener la publicación:", error);
    res.status(500).json({ error: "Error al obtener la publicación" });
  }
};

/**
 * POST /api/publicaciones
 * -------------------------------------------------------------
 * Crea una nueva publicación asignada al usuario en sesión.
 * Nace por defecto con estado_publicacion = 'disponible'.
 */
const postPublicacion = async (req, res) => {
  try {
    const { titulo, descripcion, estado } = req.body || {};
    if (typeof titulo !== "string" || titulo.trim().length < 2) {
      return res.status(400).json({ error: "Escribe un título (mínimo 2 letras)" });
    }
    if (titulo.trim().length > 150) {
      return res.status(400).json({ error: "El título es muy largo (máximo 150)" });
    }
    if (!ESTADOS.includes(estado)) {
      return res.status(400).json({ error: "El estado debe ser nuevo o usado" });
    }

    const nueva = await models.publicacion.create({
      id_usuario: req.usuario.id,
      titulo: titulo.trim(),
      descripcion: typeof descripcion === "string" ? descripcion.trim() : null,
      estado,
    });

    const publicacion = await models.publicacion.findByPk(nueva.id, {
      include: INCLUIR_USUARIOS,
    });
    res.status(201).json(publicacion);
  } catch (error) {
    console.error("Error al crear publicación:", error);
    res.status(500).json({ error: "Error al crear la publicación" });
  }
};

/**
 * PUT /api/publicaciones/:id
 * -------------------------------------------------------------
 * Edita datos informativos (título, descripción, condición físico) de una publicación propia.
 */
const putPublicacion = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;

    const { titulo, descripcion, estado } = req.body || {};
    const cambios = {};

    if (titulo !== undefined) {
      if (typeof titulo !== "string" || titulo.trim().length < 2 || titulo.trim().length > 150) {
        return res.status(400).json({ error: "El título debe tener entre 2 y 150 letras" });
      }
      cambios.titulo = titulo.trim();
    }
    if (descripcion !== undefined) {
      cambios.descripcion = typeof descripcion === "string" ? descripcion.trim() : null;
    }
    if (estado !== undefined) {
      if (!ESTADOS.includes(estado)) {
        return res.status(400).json({ error: "El estado debe ser nuevo o usado" });
      }
      cambios.estado = estado;
    }

    await publicacion.update(cambios);
    await publicacion.reload({ include: INCLUIR_USUARIOS });
    res.json({ publicacion, mensaje: "Publicación actualizada correctamente" });
  } catch (error) {
    console.error("Error al actualizar publicación:", error);
    res.status(500).json({ error: "Error al actualizar la publicación" });
  }
};

/**
 * DELETE /api/publicaciones/:id
 * -------------------------------------------------------------
 * Elimina permanentemente una publicación propia.
 */
const deletePublicacion = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;

    await publicacion.destroy();
    res.json({ mensaje: "Publicación eliminada correctamente" });
  } catch (error) {
    console.error("Error al eliminar publicación:", error);
    res.status(500).json({ error: "Error al eliminar la publicación" });
  }
};

/**
 * PUT /api/publicaciones/:id/reservado (FUNCIÓN RESERVAR)
 * -------------------------------------------------------------
 * PROPÓSITO Y FUNCIONAMIENTO:
 * Permite reservar una publicación. Esta acción puede ser realizada por:
 *  1. Un usuario interesado desde el feed público.
 *  2. El propio dueño desde "Mis publicaciones" (por ejemplo, si acordó el trueque fuera de la app).
 * 
 * ENTRADA Y PARÁMETROS:
 * - Recibe opcionalmente en el body `{ "id_usuario": <id> }` para especificar explícitamente
 *   el usuario que reserva. Si no se envía en el body, se utiliza el ID de la sesión actual (`req.usuario.id`).
 * 
 * REGLAS DE NEGOCIO:
 * - La publicación debe existir.
 * - Solo se puede reservar si está actualmente en estado 'disponible' (evita doble reserva concurrente).
 * - Actualiza 'estado_publicacion' a 'reservado'.
 * - Asigna 'id_usuario_reserva' con el ID del usuario correspondiente.
 */
const putPublicacionReservado = async (req, res) => {
  try {
    const id = leerId(req);
    if (!id) return res.status(400).json({ error: "El id no es válido" });

    const publicacion = await models.publicacion.findByPk(id, {
      include: INCLUIR_USUARIOS,
    });
    if (!publicacion) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }

    // Si ya está reservada por alguien más
    if (publicacion.estado_publicacion === "reservado") {
      return res.status(409).json({ error: "La publicación ya se encuentra reservada" });
    }

    // Determina el ID del usuario que toma la reserva
    const idUsuarioReserva =
      req.body && req.body.id_usuario ? Number(req.body.id_usuario) : req.usuario.id;

    if (!Number.isInteger(idUsuarioReserva) || idUsuarioReserva <= 0) {
      return res.status(400).json({ error: "El id del usuario que reserva no es válido" });
    }

    // Efectúa la reserva guardando el estado y la referencia del usuario
    await publicacion.update({
      estado_publicacion: "reservado",
      id_usuario_reserva: idUsuarioReserva,
    });

    // Recarga con la relación para devolver los nombres actualizados
    await publicacion.reload({ include: INCLUIR_USUARIOS });
    res.json({
      publicacion,
      mensaje: "Publicación reservada correctamente",
    });
  } catch (error) {
    console.error("Error al reservar publicación:", error);
    res.status(500).json({ error: "Error al reservar la publicación" });
  }
};

/**
 * PUT /api/publicaciones/:id/disponible (FUNCIÓN DESCARTAR RESERVA / VOLVER A DISPONIBLE)
 * -------------------------------------------------------------
 * PROPÓSITO Y FUNCIONAMIENTO:
 * Regresa la publicación al estado 'disponible' y limpia la reserva (id_usuario_reserva = NULL).
 * 
 * PERMISOS Y QUIÉN PUEDE EJECUTARLA:
 *  1. El usuario que tenía la reserva activa (acción "Descartar" desde el feed).
 *  2. El dueño de la publicación (acción "Descartar reserva" o cambio de modo desde "Mis publicaciones").
 * 
 * REGLAS DE NEGOCIO:
 * - Cambia 'estado_publicacion' a 'disponible'.
 * - Limpia 'id_usuario_reserva' a null para que el objeto quede libre de nuevo.
 */
const putPublicacionDisponible = async (req, res) => {
  try {
    const id = leerId(req);
    if (!id) return res.status(400).json({ error: "El id no es válido" });

    const publicacion = await models.publicacion.findByPk(id, {
      include: INCLUIR_USUARIOS,
    });
    if (!publicacion) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }

    // Validación de permisos: solo el dueño o la persona que la reservó pueden liberarla
    const esDueno = publicacion.id_usuario === req.usuario.id;
    const esQuienReservo = publicacion.id_usuario_reserva === req.usuario.id;

    if (!esDueno && !esQuienReservo) {
      return res.status(403).json({
        error: "No tienes permiso para liberar o descartar la reserva de esta publicación",
      });
    }

    // Pasa a disponible y elimina cualquier vínculo de reserva
    await publicacion.update({
      estado_publicacion: "disponible",
      id_usuario_reserva: null,
    });

    await publicacion.reload({ include: INCLUIR_USUARIOS });
    res.json({
      publicacion,
      mensaje: "Publicación ahora disponible para intercambio",
    });
  } catch (error) {
    console.error("Error al poner publicación en disponible:", error);
    res.status(500).json({ error: "Error al actualizar la publicación" });
  }
};

/**
 * PUT /api/publicaciones/:id/oculto
 * -------------------------------------------------------------
 * Permite al creador ocultar su publicación del feed público.
 * Si estaba reservada, se remueve la reserva.
 */
const putPublicacionOculto = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;

    await publicacion.update({
      estado_publicacion: "oculto",
      id_usuario_reserva: null,
    });

    await publicacion.reload({ include: INCLUIR_USUARIOS });
    res.json({ publicacion, mensaje: 'Publicación ahora está "oculto"' });
  } catch (error) {
    console.error("Error al ocultar publicación:", error);
    res.status(500).json({ error: "Error al cambiar el estado de la publicación" });
  }
};

/**
 * PUT /api/publicaciones/:id/no-disponible
 * -------------------------------------------------------------
 * Permite al creador marcar el objeto como no disponible (por ejemplo, trueque finalizado).
 */
const putPublicacionNoDisponible = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;

    await publicacion.update({
      estado_publicacion: "no disponible",
      id_usuario_reserva: null,
    });

    await publicacion.reload({ include: INCLUIR_USUARIOS });
    res.json({ publicacion, mensaje: 'Publicación ahora está "no disponible"' });
  } catch (error) {
    console.error("Error al marcar publicación como no disponible:", error);
    res.status(500).json({ error: "Error al cambiar el estado de la publicación" });
  }
};

module.exports = {
  ESTADOS_PUBLICACION_VALIDOS,
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

