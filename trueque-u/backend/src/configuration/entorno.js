// Configuración central. Los valores salen del archivo .env
require("dotenv").config({ override: true }); // el .env manda sobre variables del sistema

// Con una base en línea (Neon, etc.) se pega su cadena de conexión en BD_URL.
// Sin BD_URL se usan los datos sueltos: BD_HOST, BD_PUERTO, BD_NOMBRE, BD_USUARIO y BD_CONTRASENA.
function configurarBaseDeDatos() {
  const url = process.env.BD_URL;
  if (url) {
    // Las bases en línea piden conexión segura. Se escribe 'verify-full' de forma
    // explícita porque es lo que la librería pg hace con 'require' (y así no avisa).
    // También se quita 'channel_binding=require' (Neon lo agrega, pero no hace falta).
    const urlLimpia = url
      .replace("sslmode=require", "sslmode=verify-full")
      .replace(/&?channel_binding=require/, "");
    return { connectionString: urlLimpia };
  }
  return {
    host: process.env.BD_HOST || "localhost",
    port: Number(process.env.BD_PUERTO || 5432),
    database: process.env.BD_NOMBRE || "trueque_u",
    user: process.env.BD_USUARIO || "postgres",
    password: process.env.BD_CONTRASENA,
  };
}

module.exports = {
  puerto: process.env.PUERTO || 3000,
  jwtSecreto:
    process.env.JWT_SECRETO || "trueque-u-secreto-solo-para-desarrollo",
  duracionSesionDias: 7,
  // Gmail para enviar la contraseña nueva (si no se llena, se muestra en la consola).
  correo: {
    usuario: process.env.CORREO_USUARIO,
    clave: process.env.CORREO_CLAVE,
  },
  baseDeDatos: configurarBaseDeDatos(),
};
