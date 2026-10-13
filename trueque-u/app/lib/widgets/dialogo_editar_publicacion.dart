import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';
import 'banner_error.dart';
import 'campo_texto.dart';

/// =========================================================================
/// DIÁLOGO PARA EDITAR INFORMACIÓN (SOLO NOMBRE Y DESCRIPCIÓN)
/// =========================================================================
/// Permite modificar únicamente el nombre y la descripción del objeto publicado.
/// Muestra errores de validación y respuestas de error del servidor como BannerError.
class DialogoEditarPublicacion extends StatefulWidget {
  const DialogoEditarPublicacion({
    super.key,
    required this.id,
    required this.tituloInicial,
    this.descripcionInicial,
  });

  final int id;
  final String tituloInicial;
  final String? descripcionInicial;

  @override
  State<DialogoEditarPublicacion> createState() =>
      _DialogoEditarPublicacionState();
}

class _DialogoEditarPublicacionState extends State<DialogoEditarPublicacion> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.tituloInicial);
    _descripcionCtrl =
        TextEditingController(text: widget.descripcionInicial ?? '');
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await context.read<ControladorAutenticacion>().editarPublicacion(
            widget.id,
            titulo: _tituloCtrl.text,
            descripcion: _descripcionCtrl.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _guardando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Ocurrió un error al actualizar la publicación';
        _guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar información'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formulario,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTexto(
                  controlador: _tituloCtrl,
                  etiqueta: 'Nombre del objeto',
                  accionTeclado: TextInputAction.next,
                  validador: (v) {
                    final texto = (v ?? '').trim();
                    if (texto.isEmpty) return 'Escribe el nombre del objeto';
                    if (texto.length < 2) return 'Mínimo 2 letras';
                    if (texto.length > 150) return 'Máximo 150 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  controlador: _descripcionCtrl,
                  etiqueta: 'Descripción (opcional)',
                  lineas: 3,
                  tipoTeclado: TextInputType.multiline,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  BannerError(_error),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
