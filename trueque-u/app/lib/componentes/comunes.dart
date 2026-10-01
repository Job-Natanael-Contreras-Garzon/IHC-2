import 'package:flutter/material.dart';

/// Validadores compartidos por los formularios.
String? validarCorreo(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return 'Escribe tu correo';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(texto)) {
    return 'Correo no válido';
  }
  return null;
}

String? validarContrasenaNueva(String? valor) {
  if ((valor ?? '').length < 6) return 'Mínimo 6 caracteres';
  return null;
}

/// Pantalla de acceso: barra superior + contenido centrado y con scroll.
class PaginaAcceso extends StatelessWidget {
  const PaginaAcceso({super.key, required this.titulo, required this.hijos});

  final String titulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo), automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: hijos,
            ),
          ),
        ),
      ),
    );
  }
}

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
  });

  final TextEditingController controlador;
  final String etiqueta;
  final String? Function(String?)? validador;
  final TextInputType? tipoTeclado;
  final TextInputAction? accionTeclado;
  final VoidCallback? alEnviar;
  final bool ocultar;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: ocultar,
      keyboardType: tipoTeclado,
      textInputAction: accionTeclado,
      validator: validador,
      onFieldSubmitted: (_) => alEnviar?.call(),
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Mensaje de error del servidor, mostrado encima del botón.
class BannerError extends StatelessWidget {
  const BannerError(this.mensaje, {super.key});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    if (mensaje == null) return const SizedBox.shrink();
    final colores = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colores.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(mensaje!, style: TextStyle(color: colores.onErrorContainer)),
    );
  }
}

/// Botón principal que muestra un indicador mientras carga.
class BotonCarga extends StatelessWidget {
  const BotonCarga({
    super.key,
    required this.texto,
    required this.cargando,
    required this.alPresionar,
  });

  final String texto;
  final bool cargando;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: cargando ? null : alPresionar,
      child: cargando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(texto),
    );
  }
}
