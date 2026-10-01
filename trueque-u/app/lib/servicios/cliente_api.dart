import 'dart:convert';

import 'package:http/http.dart' as http;

import '../configuracion.dart';

class ExcepcionApi implements Exception {
  ExcepcionApi(this.mensaje, [this.codigoEstado]);

  final String mensaje;
  final int? codigoEstado;

  @override
  String toString() => mensaje;
}

/// Cliente HTTP mínimo hacia la API de Node.js.
class ClienteApi {
  ClienteApi({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// Token de la sesión actual (null si no hay sesión).
  String? token;

  Future<Map<String, dynamic>> get(String ruta) => _enviar('GET', ruta);

  Future<Map<String, dynamic>> post(String ruta, [Map<String, dynamic>? cuerpo]) =>
      _enviar('POST', ruta, cuerpo);

  Future<Map<String, dynamic>> put(String ruta, Map<String, dynamic> cuerpo) =>
      _enviar('PUT', ruta, cuerpo);

  Future<Map<String, dynamic>> delete(String ruta) => _enviar('DELETE', ruta);

  Future<Map<String, dynamic>> _enviar(
    String metodo,
    String ruta, [
    Map<String, dynamic>? cuerpo,
  ]) async {
    final uri = Uri.parse('$urlBaseApi$ruta');
    final cabeceras = <String, String>{'Content-Type': 'application/json'};
    if (token != null) cabeceras['Authorization'] = 'Bearer $token';

    http.Response respuesta;
    try {
      final peticion = switch (metodo) {
        'GET' => _cliente.get(uri, headers: cabeceras),
        'DELETE' => _cliente.delete(uri, headers: cabeceras),
        'PUT' => _cliente.put(uri, headers: cabeceras, body: jsonEncode(cuerpo ?? {})),
        _ => _cliente.post(uri, headers: cabeceras, body: jsonEncode(cuerpo ?? {})),
      };
      respuesta = await peticion.timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ExcepcionApi(
        'No se pudo conectar con el servidor. ¿Está encendido el backend?',
      );
    }

    Map<String, dynamic> datos = {};
    if (respuesta.body.isNotEmpty) {
      try {
        datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
      } catch (_) {}
    }

    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) return datos;
    throw ExcepcionApi(
      (datos['error'] as String?) ?? 'Error inesperado (${respuesta.statusCode})',
      respuesta.statusCode,
    );
  }
}
