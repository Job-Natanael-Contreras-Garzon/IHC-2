import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Datos de configuración que salen del archivo .env
class ConfiguracionEntorno {
  ConfiguracionEntorno._();

  /// Dirección del servidor (sin /api). Si el .env no la trae, usa la local.
  static String get _servidor {
    final url = dotenv.env['API_URL'];
    if (url == null || url.isEmpty) return 'http://localhost:3000';
    // Se quitan las barras del final para no generar "//api"
    return url.replaceAll(RegExp(r'/+$'), '');
  }

  /// Dirección base de las peticiones, por ejemplo https://ihc-2.onrender.com/api
  static String get urlBase => '$_servidor/api';
}
