# Tarea 1: manejo de acceso

## Modalidad

**Backend propio en Node.js (Express) + base de datos PostgreSQL + app Flutter**, con sesión basada en **token** que se guarda en el dispositivo.
Las pantallas de acceso quedan como un módulo independiente dentro de la app de Trueque U (pantallas "desconectadas" del resto de la aplicación, que aún no existe).

- Las personas, y las sesiones viven en PostgreSQL (`base_de_datos/`).
- La app guarda el token en el dispositivo (`SharedPreferences`; en web usa `localStorage`).
- La app se probó pensando en ejecución en **Chrome** (Flutter Web), que permite mostrar la recarga y el cambio de URL en el video.

## Funcionalidad cubierta

| Requisito | Dónde está |
|---|---|
| Registro de cuenta nueva | `POST /api/usuarios` (`postUsuario`) · `pantalla_registro.dart` |
| Inicio de sesión | `POST /api/sesiones` (`postSesion`) · `pantalla_iniciar_sesion.dart` |
| Cierre de sesión | `DELETE /api/sesiones/actual` (`deleteSesion`) · botón en `pantalla_perfil.dart` |
| Recuperación de contraseña por correo | `POST /api/recuperaciones` (`postRecuperacion`) · `correo.servicio.js` · `pantalla_recuperar_contrasena.dart` |
| Cambio de contraseña | `PUT /api/usuarios/contrasena` (`putContrasena`) · `pantalla_cambiar_contrasena.dart` |
| Sesión conservada al recargar | `restaurarSesion()` en `main.dart` · `GET /api/sesiones/actual` (`getSesionActual`) |
| Ruta pública | `/` (`pantalla_inicio.dart`) |
| Ruta privada que redirige al login | `/perfil` y `/cambiar-contrasena` (`rutas.dart`) |
| Nombre de la persona en la ruta privada | `pantalla_perfil.dart` ("Hola, nombre") |

Solo se implementó lo solicitado: la pantalla de inicio no tiene ningún botón hacia la ruta privada; para probarla se cambia la URL a `/#/perfil`.

## Base de datos

Dos tablas, con nombres en español (`base_de_datos/estructura.sql`):

| Tabla | Para qué sirve |
|---|---|
| `usuarios` | Nombre, correo (único, en minúsculas) y contraseña cifrada |
| `sesiones` | Una fila por cada inicio de sesión o registro; al cerrar sesión se llena `cerrada_en` |

`base_de_datos/datos.sql` carga 3 usuarios de prueba (las contraseñas están cifradas con bcrypt; sus datos están en el README).

## Decisiones

1. **PostgreSQL.** Gratuito, estándar en backend, y se administra fácil con pgAdmin. Los scripts son simples y se cargan pegándolos tal cual.
2. **Sesión guardada en la base.** Cada token lleva el id de su fila en `sesiones`. Cerrar sesión marca esa fila como cerrada, así un token copiado deja de servir. Una sesión también vence a los 7 días.
3. **Contraseñas con bcrypt.** Nunca se guardan en texto plano. Mínimo 6 caracteres.
4. **Recuperación por correo.** El servidor crea una contraseña nueva de 8 caracteres, la guarda cifrada y la envía por Gmail (`nodemailer`). Cambiarla después es opcional. Sin datos de Gmail en el `.env`, se muestra en la consola del backend.
5. **Sesión restaurada antes de mostrar la primera pantalla.** `main()` espera `restaurarSesion()` antes de `runApp`; así, si se recarga estando en `/perfil`, el router ya sabe que hay sesión y no manda al login por error.
6. **`go_router` con `redirect`.** Una sola función decide qué rutas son privadas y se vuelve a evaluar sola cuando la sesión cambia (inicio o cierre).
7. **Backend separado por capas**: rutas → controladores → modelos (SQL), con middleware, servicios y utilidades aparte. Cada archivo hace una sola cosa y es fácil agregar módulos nuevos (publicaciones, chat) sin tocar lo de acceso.
8. **Código en español.** Carpetas, archivos, funciones y variables. Se mantienen en inglés solo los métodos HTTP (`GET`, `POST`, `PUT`, `DELETE`) y los nombres propios del framework.
9. **Estado con `provider` + `ChangeNotifier`.** Suficiente para esta tarea y fácil de explicar.
10. **Base local o en línea con el mismo código.** El backend acepta una cadena de conexión (`BD_URL`, por ejemplo la de Neon) o los datos sueltos `BD_*` para un PostgreSQL instalado. Solo el backend se conecta a la base; la app Flutter nunca recibe sus credenciales.

## Archivos principales

```
base_de_datos/estructura.sql                Tablas
base_de_datos/datos.sql                     3 usuarios de prueba
backend/src/servidor.js                     Arranque del servidor (comprueba la base)
backend/src/aplicacion.js                   Express: cors, json, rutas y errores
backend/src/rutas/                          URLs: usuarios, sesiones y recuperaciones
backend/src/controladores/                  postUsuario, putContrasena, postSesion, getSesionActual, deleteSesion, postRecuperacion
backend/src/modelos/                        Consultas SQL de cada tabla
backend/src/middleware/autenticacion.middleware.js   exigirSesion: valida token y que la sesión siga abierta
backend/src/servicios/                      Cifrado de contraseñas y tokens
backend/src/bd/conexion.js                  Conexión a PostgreSQL y transacciones
app/lib/main.dart                           Arranque: restaura la sesión y monta la app
app/lib/rutas.dart                          Rutas y redirecciones pública/privada
app/lib/estado/controlador_autenticacion.dart   Registro, sesión, recuperación y cambio de contraseña
app/lib/servicios/cliente_api.dart          Cliente HTTP con el token
app/lib/pantallas/                          Una pantalla por archivo
```

## Cómo probar el recorrido

1. Abrir `/` sin sesión (pública).
2. Escribir `/#/perfil` en la barra de direcciones: redirige al inicio de sesión.
3. Crear una cuenta (o entrar con un usuario de prueba): llega a `/perfil` con "Hola, nombre".
4. Recargar el navegador (F5): la sesión se mantiene.
5. Cambiar contraseña desde el perfil.
6. Cerrar sesión: vuelve al inicio de sesión. Escribir `/#/perfil` redirige otra vez.
7. "¿Olvidaste tu contraseña?": pedir la contraseña nueva y entrar con ella.

## Guion del video (máx. 2 minutos)

| Tiempo | Qué mostrar |
|---|---|
| 0:00–0:10 | Backend y app iniciados con los comandos del README; mencionar la base en PostgreSQL |
| 0:10–0:25 | Ruta pública `/` abierta sin sesión; escribir `/#/perfil` en la barra: redirige al inicio de sesión |
| 0:25–0:50 | Registro de una cuenta nueva → llega a `/perfil` con "Hola, nombre" |
| 0:50–1:00 | Recargar con F5: la sesión sigue activa |
| 1:00–1:15 | Cambiar contraseña desde el perfil |
| 1:15–1:25 | Cerrar sesión → inicio de sesión; escribir `/#/perfil` → vuelve al inicio de sesión |
| 1:25–1:50 | Recuperar contraseña: pedir contraseña nueva, iniciar sesión con ella |
| 1:50–2:00 | Mostrar el historial de commits y cerrar |

## Verificación realizada

- **Base de datos y backend:** los dos scripts SQL se cargaron sin errores en un PostgreSQL 16 real y todos los endpoints se probaron con `curl` contra esa base: registro (y correo repetido o datos inválidos), inicio de sesión de los 3 usuarios de prueba, sesión con token válido, falso y sin token, cierre de sesión (el token deja de servir, las demás sesiones siguen), recuperación (la contraseña nueva funciona y la anterior deja de servir), cambio de contraseña, ruta inexistente y JSON mal formado.
- **App Flutter:** escrita para esta tarea y revisada (llaves, imports, rutas y nombres que coinciden con la API), pero **debe ejecutarse una primera vez** en un equipo con Flutter para confirmar que compila y recorrer las pantallas.
