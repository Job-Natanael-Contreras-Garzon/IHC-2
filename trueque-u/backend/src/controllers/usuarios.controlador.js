const { transaccion } = require("../database/conexion");
const {
  buscarUsuarioPorCorreo,
  crearUsuario,
  actualizarContrasenaUsuario,
  buscarContrasenaHashPorId,
} = require("../models/usuarios.modelo");
const { crearSesion } = require("../models/sesiones.modelo");
const { cifrar, coincide } = require("../services/contrasena.servicio");
const { firmarToken } = require("../services/token.servicio");
const { esCorreoValido, validarContrasena } = require("../utils/validaciones");
const { usuarioPublico } = require("../utils/serializadores");

// POST /api/usuarios  ->  registro de una cuenta nueva (queda con la sesión iniciada)
async function postUsuario(req, res) {
  const { nombre, correo, contrasena } = req.body || {};
  if (typeof nombre !== "string" || nombre.trim().length < 2) {
    return res
      .status(400)
      .json({ error: "Escribe tu nombre (mínimo 2 letras)" });
  }
  if (!esCorreoValido(correo)) {
    return res.status(400).json({ error: "Correo no válido" });
  }
  const errorContrasena = validarContrasena(contrasena);
  if (errorContrasena) return res.status(400).json({ error: errorContrasena });

  const correoNormalizado = correo.trim().toLowerCase();
  if (await buscarUsuarioPorCorreo(correoNormalizado)) {
    return res
      .status(409)
      .json({ error: "Ya existe una cuenta con ese correo" });
  }

  const contrasenaHash = await cifrar(contrasena);
  try {
    const { usuario, sesionId } = await transaccion(async (ejecutar) => {
      const usuario = await crearUsuario(
        { nombre: nombre.trim(), correo: correoNormalizado, contrasenaHash },
        ejecutar,
      );
      const sesionId = await crearSesion(usuario.id, ejecutar);
      return { usuario, sesionId };
    });
    console.log(`[usuarios] Creado: id ${usuario.id}`);
    res.status(201).json({
      token: firmarToken({ usuarioId: usuario.id, sesionId }),
      usuario: usuarioPublico(usuario),
    });
  } catch (error) {
    // 23505 = correo repetido (dos registros al mismo tiempo)
    if (error.code === "23505") {
      return res
        .status(409)
        .json({ error: "Ya existe una cuenta con ese correo" });
    }
    throw error;
  }
}

// PUT /api/usuarios/contrasena  ->  cambio de contraseña con la sesión iniciada
async function putContrasena(req, res) {
  const { contrasenaActual, contrasenaNueva } = req.body || {};
  if (typeof contrasenaActual !== "string") {
    return res.status(400).json({ error: "Escribe tu contraseña actual" });
  }
  const errorContrasena = validarContrasena(contrasenaNueva);
  if (errorContrasena) return res.status(400).json({ error: errorContrasena });

  const hashActual = await buscarContrasenaHashPorId(req.usuario.id);
  if (!hashActual || !(await coincide(contrasenaActual, hashActual))) {
    return res
      .status(400)
      .json({ error: "La contraseña actual no es correcta" });
  }

  await actualizarContrasenaUsuario(
    req.usuario.id,
    await cifrar(contrasenaNueva),
  );
  console.log(`[usuarios] Contraseña actualizada: usuario ${req.usuario.id}`);
  res.json({ ok: true, mensaje: "Contraseña actualizada" });
}

module.exports = { postUsuario, putContrasena };
