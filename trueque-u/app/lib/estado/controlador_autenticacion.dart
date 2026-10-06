import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../servicios/cliente_api.dart';

/// Representa al usuario que tiene la sesión iniciada en la aplicación.
class UsuarioAutenticado {
  const UsuarioAutenticado({
    required this.id,
    required this.nombre,
    this.correo,
  });

  final int id;
  final String nombre;
  final String? correo;

  factory UsuarioAutenticado.desdeJson(Map<String, dynamic> json) =>
      UsuarioAutenticado(
        id: (json['id'] as num?)?.toInt() ?? 0,
        nombre: json['nombre'] as String? ?? '',
        correo: json['correo'] as String?,
      );
}

/// Maneja la sesión: registro, inicio y cierre de sesión, recuperación y cambio
/// de contraseña. El token se guarda en SharedPreferences (localStorage en web),
/// así la sesión sobrevive a recargar la aplicación.
class ControladorAutenticacion extends ChangeNotifier {
  ControladorAutenticacion(this._api, this._preferencias);

  static const _claveToken = 'trueque_token';

  final ClienteApi _api;
  final SharedPreferences _preferencias;

  UsuarioAutenticado? _usuario;
  UsuarioAutenticado? get usuario => _usuario;
  bool get autenticado => _usuario != null;

  /// Se llama una vez al iniciar la app: si hay un token guardado, lo valida
  /// con el servidor y recupera a la persona.
  Future<void> restaurarSesion() async {
    final guardado = _preferencias.getString(_claveToken);
    if (guardado == null) return;

    _api.token = guardado;
    try {
      final datos = await _api.get('/sesiones/actual');
      _usuario = UsuarioAutenticado.desdeJson(datos['usuario'] as Map<String, dynamic>);
    } on ExcepcionApi catch (e) {
      // Sesión cerrada o vencida: se descarta. Si solo falló la red, el token
      // se conserva para un próximo intento.
      if (e.codigoEstado == 401) await _borrarSesion();
    }
    notifyListeners();
  }

  Future<void> registrar(String nombre, String correo, String contrasena) async {
    final datos = await _api.post('/usuarios', {
      'nombre': nombre.trim(),
      'correo': correo.trim(),
      'contrasena': contrasena,
    });
    await _guardarSesion(datos);
  }

  Future<void> iniciarSesion(String correo, String contrasena) async {
    final datos = await _api.post('/sesiones', {
      'correo': correo.trim(),
      'contrasena': contrasena,
    });
    await _guardarSesion(datos);
  }

  Future<void> cerrarSesion() async {
    try {
      await _api.delete('/sesiones/actual');
    } on ExcepcionApi {
      // Aunque el servidor no responda, la sesión local se cierra igual.
    }
    await _borrarSesion();
    notifyListeners();
  }

  /// Pide una contraseña nueva: el servidor la envía al correo de la persona.
  Future<void> recuperarContrasena(String correo) async {
    await _api.post('/recuperaciones', {'correo': correo.trim()});
  }

  ClienteApi get api => _api;

  Future<void> cambiarContrasena(String contrasenaActual, String contrasenaNueva) async {
    await _api.put('/usuarios/contrasena', {
      'contrasenaActual': contrasenaActual,
      'contrasenaNueva': contrasenaNueva,
    });
  }

  /// Crea una nueva publicación de objeto para intercambiar.
  Future<void> crearPublicacion({
    required String titulo,
    String? descripcion,
    required String estado,
  }) async {
    await _api.post('/publicaciones', {
      'titulo': titulo.trim(),
      if (descripcion != null && descripcion.trim().isNotEmpty)
        'descripcion': descripcion.trim(),
      'estado': estado,
    });
  }

  /// Obtiene las publicaciones creadas por la persona con sesión activa.
  Future<List<Map<String, dynamic>>> obtenerMisPublicaciones() async {
    final respuesta = await _api.get('/publicaciones/mias');
    if (respuesta is List) {
      return respuesta.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Obtiene todas las publicaciones visibles para el feed general (cards en grid).
  Future<List<Map<String, dynamic>>> obtenerPublicacionesFeed() async {
    final respuesta = await _api.get('/publicaciones');
    if (respuesta is List) {
      return respuesta.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Reserva una publicación enviando el ID del usuario en sesión o el provisto.
  /// Llama a PUT /api/publicaciones/:id/reservado
  Future<void> reservarPublicacion(int id, {int? idUsuario}) async {
    final idParaEnviar = idUsuario ?? _usuario?.id;
    await _api.put('/publicaciones/$id/reservado', {
      if (idParaEnviar != null) 'id_usuario': idParaEnviar,
    });
  }

  /// Descarta o cancela una reserva activa, regresando el objeto a 'disponible'.
  /// Llama a PUT /api/publicaciones/:id/disponible
  Future<void> descartarReservaPublicacion(int id) async {
    await _api.put('/publicaciones/$id/disponible', {});
  }

  /// Permite al creador alternar libremente entre los estados de publicación:
  /// 'disponible', 'reservado', 'oculto', 'no disponible'.
  Future<void> cambiarEstadoPublicacion(
    int id,
    String nuevoEstado, {
    int? idUsuario,
  }) async {
    switch (nuevoEstado) {
      case 'disponible':
        await descartarReservaPublicacion(id);
        break;
      case 'reservado':
        await reservarPublicacion(id, idUsuario: idUsuario);
        break;
      case 'oculto':
        await _api.put('/publicaciones/$id/oculto', {});
        break;
      case 'no disponible':
        await _api.put('/publicaciones/$id/no-disponible', {});
        break;
      default:
        throw ArgumentError('Estado no válido: $nuevoEstado');
    }
  }

  /// Elimina una publicación propia por su ID.
  Future<void> eliminarPublicacion(int id) async {
    await _api.delete('/publicaciones/$id');
  }

  Future<void> _guardarSesion(Map<String, dynamic> datos) async {
    final token = datos['token'] as String;
    _api.token = token;
    await _preferencias.setString(_claveToken, token);
    _usuario = UsuarioAutenticado.desdeJson(datos['usuario'] as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> _borrarSesion() async {
    _api.token = null;
    _usuario = null;
    await _preferencias.remove(_claveToken);
  }
}
