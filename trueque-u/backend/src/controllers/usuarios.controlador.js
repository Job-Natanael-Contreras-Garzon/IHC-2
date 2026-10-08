const { sequelize, models } = require("../database/sequelize");
const { crearSesion } = require("../services/sesion.servicio");
const { cifrar, coincide } = require("../services/contrasena.servicio");
const { firmarToken } = require("../services/token.servicio");
const { esCorreoValido, validarContrasena } = require("../utils/validaciones");
const { usuarioPublico } = require("../utils/serializadores");

// POST /api/usuarios
// Registra una cuenta nueva y deja la sesión iniciada
const postUsuario = async (req, res) => {
  try {
    const { nombre, correo, contrasena } = req.body || {};

    // Se validan los datos que llegan
    if (typeof nombre !== "string" || nombre.trim().length < 2) {
      return res
        .status(400)
        .json({ error: "Escribe tu nombre (mínimo 2 letras)" });
    }
    if (!esCorreoValido(correo)) {
      return res.status(400).json({ error: "Correo no válido" });
    }
    const errorContrasena = validarContrasena(contrasena);
    if (errorContrasena) {
      return res.status(400).json({ error: errorContrasena });
    }

    // El correo se guarda en minúsculas y no puede repetirse
    const correoNormalizado = correo.trim().toLowerCase();
    const existente = await models.usuarios.findOne({
      where: { correo: correoNormalizado },
    });
    if (existente) {
      return res
        .status(409)
        .json({ error: "Ya existe una cuenta con ese correo" });
    }

    // La contraseña nunca se guarda tal cual, se guarda cifrada
    const contrasenaHash = await cifrar(contrasena);

    // Se crea el usuario y su sesión juntos: si algo falla, no se guarda nada
    const { usuario, sesionId } = await sequelize.transaction(async (t) => {
      const usuario = await models.usuarios.create(
        {
          nombre: nombre.trim(),
          correo: correoNormalizado,
          contrasena_hash: contrasenaHash,
        },
        { transaction: t },
      );
      const sesionId = await crearSesion(usuario.id, t);
      return { usuario, sesionId };
    });

    console.log(`[usuarios] Creado: id ${usuario.id}`);
    res.status(201).json({
      token: firmarToken({ usuarioId: usuario.id, sesionId }),
      usuario: usuarioPublico(usuario),
    });
  } catch (error) {
    // Dos registros con el mismo correo al mismo tiempo
    if (error.name === "SequelizeUniqueConstraintError") {
      return res
        .status(409)
        .json({ error: "Ya existe una cuenta con ese correo" });
    }
    console.error("Error al crear usuario:", error);
    res.status(500).json({ error: "Error al crear la cuenta" });
  }
};

// PUT /api/usuarios/contrasena
// Cambia la contraseña de la persona que tiene la sesión iniciada
const putContrasena = async (req, res) => {
  try {
    const { contrasenaActual, contrasenaNueva } = req.body || {};

    if (typeof contrasenaActual !== "string") {
      return res.status(400).json({ error: "Escribe tu contraseña actual" });
    }
    const errorContrasena = validarContrasena(contrasenaNueva);
    if (errorContrasena) {
      return res.status(400).json({ error: errorContrasena });
    }

    // Se comprueba que la contraseña actual sea la correcta
    const usuario = await models.usuarios.findByPk(req.usuario.id);
    if (!usuario || !(await coincide(contrasenaActual, usuario.contrasena_hash))) {
      return res
        .status(400)
        .json({ error: "La contraseña actual no es correcta" });
    }

    // Se guarda la contraseña nueva (cifrada)
    await usuario.update({ contrasena_hash: await cifrar(contrasenaNueva) });

    console.log(`[usuarios] Contraseña actualizada: usuario ${usuario.id}`);
    res.json({ ok: true, mensaje: "Contraseña actualizada" });
  } catch (error) {
    console.error("Error al cambiar la contraseña:", error);
    res.status(500).json({ error: "Error al cambiar la contraseña" });
  }
};

module.exports = { postUsuario, putContrasena };
