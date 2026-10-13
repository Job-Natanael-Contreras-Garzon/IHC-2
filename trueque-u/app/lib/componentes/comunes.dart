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

// El teléfono es opcional; si se escribe, deben ser 8 dígitos
String? validarTelefonoOpcional(String? valor) {
  final texto = (valor ?? '').trim();
  if (texto.isEmpty) return null;
  if (!RegExp(r'^\d{8}$').hasMatch(texto)) return 'El teléfono debe tener 8 dígitos';
  return null;
}

// Categorías de las publicaciones: lo que se guarda -> lo que se muestra
const etiquetasCategoria = {
  'libros': 'Libros',
  'electronica': 'Electrónica',
  'ropa': 'Ropa',
  'otros': 'Otros',
};

// Condición del objeto
const etiquetasCondicion = {
  'nuevo': 'Nuevo',
  'usado': 'Usado',
};

// Disponibilidad que se puede filtrar en el catálogo
const etiquetasDisponibilidad = {
  'disponible': 'Disponible',
  'reservado': 'Reservado',
  'intercambiado': 'Intercambiado',
};

/// Pregunta "¿seguro?" antes de una acción. Devuelve true si la persona acepta.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoBoton,
}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(textoBoton),
        ),
      ],
    ),
  );
  return respuesta == true;
}

String? validarContrasenaNueva(String? valor) {
  if ((valor ?? '').length < 6) return 'Mínimo 6 caracteres';
  return null;
}

/// Pantalla de acceso: barra superior + contenido centrado y con scroll.
class PaginaAcceso extends StatelessWidget {
  const PaginaAcceso({
    super.key,
    required this.titulo,
    required this.hijos,
    this.alVolver,
    this.acciones,
    this.anchoMaximo = 420,
    this.botonFlotante,
  });

  final String titulo;
  final List<Widget> hijos;
  final VoidCallback? alVolver;
  final List<Widget>? acciones;
  final double anchoMaximo;
  final Widget? botonFlotante;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        automaticallyImplyLeading: false,
        leading: alVolver != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: alVolver,
              )
            : null,
        actions: acciones,
      ),
      floatingActionButton: botonFlotante,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: anchoMaximo),
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
