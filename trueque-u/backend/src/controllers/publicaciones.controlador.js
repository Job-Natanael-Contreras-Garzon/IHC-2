const { models } = require("../database/sequelize");

const ESTADOS = ["nuevo", "usado"];

// Cambios de estado permitidos: desde qué estado_publicacion se puede ir a cuál.
const CAMBIOS_PERMITIDOS = {
  disponible: ["oculto", "reservado", "no disponible"],
  reservado: ["disponible", "no disponible"],
  oculto: ["disponible"],
  "no disponible": ["disponible"],
};

// Lee el :id de la URL. Devuelve null si no es un número.
function leerId(req) {
  const id = Number(req.params.id);
  return Number.isInteger(id) && id > 0 ? id : null;
}

// Busca una publicación que sea de quien tiene la sesión abierta.
// Si no existe o es de otra persona, ya responde el error y devuelve null.
async function buscarPublicacionPropia(req, res) {
  const id = leerId(req);
  if (!id) {
    res.status(400).json({ error: "El id no es válido" });
    return null;
  }
  const publicacion = await models.publicacion.findByPk(id);
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

// GET /api/publicaciones  ->  todas las publicaciones disponibles (de todas las personas)
const getPublicaciones = async (req, res) => {
  try {
    const publicaciones = await models.publicacion.findAll({
      where: { estado_publicacion: "disponible" },
      order: [["id", "DESC"]],
    });
    res.json(publicaciones);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al obtener las publicaciones" });
  }
};

// GET /api/publicaciones/mias  ->  mis publicaciones, en cualquier estado
const getMisPublicaciones = async (req, res) => {
  try {
    const publicaciones = await models.publicacion.findAll({
      where: { id_usuario: req.usuario.id },
      order: [["id", "DESC"]],
    });
    res.json(publicaciones);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al obtener tus publicaciones" });
  }
};

// GET /api/publicaciones/:id  ->  una publicación (las ocultas solo las ve su dueño)
const getPublicacion = async (req, res) => {
  try {
    const id = leerId(req);
    if (!id) return res.status(400).json({ error: "El id no es válido" });

    const publicacion = await models.publicacion.findByPk(id);
    const esOculta = publicacion && publicacion.estado_publicacion === "oculto";
    if (!publicacion || (esOculta && publicacion.id_usuario !== req.usuario.id)) {
      return res.status(404).json({ error: "Publicación no encontrada" });
    }
    res.json(publicacion);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al obtener la publicación" });
  }
};

// POST /api/publicaciones  ->  crear una publicación (queda disponible)
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

    const publicacion = await models.publicacion.create({
      id_usuario: req.usuario.id, // siempre es quien tiene la sesión abierta
      titulo: titulo.trim(),
      descripcion: typeof descripcion === "string" ? descripcion.trim() : null,
      estado,
    });
    res.status(201).json(publicacion);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al crear la publicación" });
  }
};

// PUT /api/publicaciones/:id  ->  editar título, descripción o estado (nuevo/usado)
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
    res.json({ publicacion, mensaje: "Publicación actualizada correctamente" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al actualizar la publicación" });
  }
};

// DELETE /api/publicaciones/:id  ->  eliminar una publicación
const deletePublicacion = async (req, res) => {
  try {
    const publicacion = await buscarPublicacionPropia(req, res);
    if (!publicacion) return;

    await publicacion.destroy();
    res.json({ mensaje: "Publicación eliminada correctamente" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al eliminar la publicación" });
  }
};

// Crea el controlador que cambia estado_publicacion a "nuevoEstado".
function cambiarEstadoPublicacion(nuevoEstado) {
  return async (req, res) => {
    try {
      const publicacion = await buscarPublicacionPropia(req, res);
      if (!publicacion) return;

      const permitidos = CAMBIOS_PERMITIDOS[publicacion.estado_publicacion] || [];
      if (!permitidos.includes(nuevoEstado)) {
        return res.status(409).json({
          error: `No se puede pasar de "${publicacion.estado_publicacion}" a "${nuevoEstado}"`,
        });
      }

      await publicacion.update({ estado_publicacion: nuevoEstado });
      res.json({ publicacion, mensaje: `Publicación ahora está "${nuevoEstado}"` });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Error al cambiar el estado de la publicación" });
    }
  };
}

// PUT /api/publicaciones/:id/disponible     (desde oculto, reservado o no disponible)
const putPublicacionDisponible = cambiarEstadoPublicacion("disponible");
// PUT /api/publicaciones/:id/oculto         (desde disponible)
const putPublicacionOculto = cambiarEstadoPublicacion("oculto");
// PUT /api/publicaciones/:id/reservado      (desde disponible)
const putPublicacionReservado = cambiarEstadoPublicacion("reservado");
// PUT /api/publicaciones/:id/no-disponible  (desde disponible o reservado)
const putPublicacionNoDisponible = cambiarEstadoPublicacion("no disponible");

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
