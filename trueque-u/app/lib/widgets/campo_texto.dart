import 'package:flutter/material.dart';

/// Campo de texto con borde, usado en todos los formularios.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.validador,
    this.tipoTeclado,
    this.accionTeclado,
    this.alEnviar,
    this.ocultar = false,
    this.lineas = 1,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final TextInputAction? accionTeclado;
  final VoidCallback? alEnviar;
  final bool ocultar;
  final int lineas;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: ocultar,
      keyboardType: tipoTeclado,
      textInputAction: accionTeclado,
      maxLines: ocultar ? 1 : lineas,
      validator: validador,
      onFieldSubmitted: (_) => alEnviar?.call(),
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
