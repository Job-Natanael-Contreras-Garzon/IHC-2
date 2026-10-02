import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../componentes/comunes.dart';
import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';

/// Formulario para crear una nueva publicación de trueque.
class PantallaPublicacion extends StatefulWidget {
  const PantallaPublicacion({super.key});

  @override
  State<PantallaPublicacion> createState() => _PantallaPublicacionState();
}

class _PantallaPublicacionState extends State<PantallaPublicacion> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  String _estado = 'nuevo'; // 'nuevo' o 'usado'
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await context.read<ControladorAutenticacion>().crearPublicacion(
            titulo: _nombre.text,
            descripcion: _descripcion.text,
            estado: _estado,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación guardada exitosamente')),
      );
      // Cierra la pantalla y vuelve a pantalla_perfil.dart
      context.go('/perfil');
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Ocurrió un error al guardar la publicación';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginaAcceso(
      titulo: 'Nueva publicación',
      alVolver: () => context.go('/perfil'),
      hijos: [
        Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTexto(
                controlador: _nombre,
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
                controlador: _descripcion,
                etiqueta: 'Descripción (opcional)',
                lineas: 3,
                tipoTeclado: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado del objeto',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'nuevo', child: Text('Nuevo')),
                  DropdownMenuItem(value: 'usado', child: Text('Usado')),
                ],
                onChanged: (valor) {
                  if (valor != null) {
                    setState(() => _estado = valor);
                  }
                },
              ),
              const SizedBox(height: 20),
              BannerError(_error),
              BotonCarga(
                texto: 'Guardar',
                cargando: _cargando,
                alPresionar: _guardar,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/perfil'),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
