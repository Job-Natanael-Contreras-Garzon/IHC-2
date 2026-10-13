/// Validadores compartidos por los formularios.
String? validarCorreo(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return 'Escribe tu correo';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(texto)) {
    return 'Correo no válido';
  }
  return null;
}

// El teléfono es opcional; si se escribe, deben ser 8 dígitos
String? validarTelefonoOpcional(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return null;
  if (!RegExp(r'^\d{8}$').hasMatch(texto)) return 'El teléfono debe tener 8 dígitos';
  return null;
}

String? validarContrasenaNueva(String? valor) {
  if ((valor ?? '').length < 6) return 'Mínimo 6 caracteres';
  return null;
}
