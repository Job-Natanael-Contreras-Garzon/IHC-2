import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre el chat de WhatsApp con un teléfono de Bolivia (+591).
/// Si hay un [mensaje], el chat se abre con ese texto ya escrito.
Future<void> abrirWhatsapp(
  BuildContext context,
  String telefono, {
  String? mensaje,
}) async {
  final texto = mensaje == null ? '' : '?text=${Uri.encodeComponent(mensaje)}';
  final enlace = Uri.parse('https://wa.me/591$telefono$texto');
  bool abierto = false;
  try {
    abierto = await launchUrl(enlace, mode: LaunchMode.externalApplication);
  } catch (_) {
    abierto = false;
  }
  if (!abierto && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se pudo abrir WhatsApp. Revisa que esté instalado o inténtalo desde el navegador.',
        ),
      ),
    );
  }
}
