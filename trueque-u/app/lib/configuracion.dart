import 'package:flutter/foundation.dart';

/// Dirección del backend. Se puede cambiar al ejecutar:
///   flutter run -d chrome --dart-define=URL_API=http://192.168.1.10:3000/api
const String _urlApiManual = String.fromEnvironment('URL_API');

String get urlBaseApi {
  if (_urlApiManual.isNotEmpty) return _urlApiManual;
  // El emulador de Android ve el computador como 10.0.2.2
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000/api';
  }
  return 'http://localhost:3000/api';
}
