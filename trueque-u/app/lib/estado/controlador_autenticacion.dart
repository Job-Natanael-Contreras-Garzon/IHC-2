import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../servicios/cliente_api.dart';

class UsuarioAutenticado {
  const UsuarioAutenticado({required this.nombre});

  final String nombre;

  factory UsuarioAutenticado.desdeJson(Map<String, dynamic> json) =>
      UsuarioAutenticado(nombre: json['nombre'] as String);
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

  Future<void> cambiarContrasena(String contrasenaActual, String contrasenaNueva) async {
    await _api.put('/usuarios/contrasena', {
      'contrasenaActual': contrasenaActual,
      'contrasenaNueva': contrasenaNueva,
    });
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
