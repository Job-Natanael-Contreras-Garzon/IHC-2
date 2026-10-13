const { Op } = require("sequelize");

// Se reemplaza la base de datos por una falsa: así la prueba no necesita conexión
jest.mock("../database/sequelize", () => ({
  models: {
    publicaciones: { findAll: jest.fn() },
    usuarios: {},
  },
}));

const { models } = require("../database/sequelize");
const { getPublicaciones } = require("./publicaciones.controlador");

// Respuesta falsa de Express para poder ver qué devolvió el controlador
function crearRespuesta() {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  return res;
}

describe("Buscar y filtrar publicaciones", () => {
  beforeEach(() => {
    models.publicaciones.findAll.mockReset();
  });

  // CASO CON RESULTADOS: libros usados disponibles que tengan "algebra" en el título
  test("combina búsqueda y filtros y devuelve las publicaciones encontradas", async () => {
    const encontrada = { id: 1, titulo: "Libro de algebra", categoria: "libros" };
    models.publicaciones.findAll.mockResolvedValue([encontrada]);

    const req = {
      query: {
        buscar: "algebra",
        categoria: "libros",
        condicion: "usado",
        disponibilidad: "disponible",
      },
    };
    const res = crearRespuesta();
    await getPublicaciones(req, res);

    // Lo que se le pidió a la base de datos
    const consulta = models.publicaciones.findAll.mock.calls[0][0];
    expect(consulta.where.titulo).toEqual({ [Op.iLike]: "%algebra%" });
    expect(consulta.where.categoria).toBe("libros");
    expect(consulta.where.estado).toBe("usado");
    expect(consulta.where.estado_publicacion).toBe("disponible");

    // Lo que se devolvió a la app
    expect(res.json).toHaveBeenCalledWith([encontrada]);
  });

  // CASO SIN RESULTADOS: ninguna publicación coincide
  test("si nada coincide devuelve una lista vacía", async () => {
    models.publicaciones.findAll.mockResolvedValue([]);

    const req = { query: { buscar: "no existe", categoria: "ropa" } };
    const res = crearRespuesta();
    await getPublicaciones(req, res);

    expect(res.json).toHaveBeenCalledWith([]);
  });

  test("sin filtros no muestra las ocultas ni las intercambiadas", async () => {
    models.publicaciones.findAll.mockResolvedValue([]);

    const res = crearRespuesta();
    await getPublicaciones({ query: {} }, res);

    const consulta = models.publicaciones.findAll.mock.calls[0][0];
    expect(consulta.where.estado_publicacion).toEqual({
      [Op.notIn]: ["oculto", "intercambiado"],
    });
  });

  test("una disponibilidad que no existe da error 400", async () => {
    const res = crearRespuesta();
    await getPublicaciones({ query: { disponibilidad: "loquesea" } }, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(models.publicaciones.findAll).not.toHaveBeenCalled();
  });
});
