import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../componentes/comunes.dart';
import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await context
          .read<ControladorAutenticacion>()
          .registrar(_nombre.text, _correo.text, _contrasena.text);
      if (!mounted) return;
      // La cuenta nueva queda con la sesión iniciada.
      context.go('/perfil');
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaginaAcceso(
      titulo: 'Crear cuenta',
      hijos: [
        Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTexto(
                controlador: _nombre,
                etiqueta: 'Nombre completo',
                accionTeclado: TextInputAction.next,
                validador: (v) =>
                    (v ?? '').trim().length < 2 ? 'Escribe tu nombre' : null,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _correo,
                etiqueta: 'Correo',
                tipoTeclado: TextInputType.emailAddress,
                accionTeclado: TextInputAction.next,
                validador: validarCorreo,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _contrasena,
                etiqueta: 'Contraseña',
                ocultar: true,
                accionTeclado: TextInputAction.next,
                validador: validarContrasenaNueva,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _confirmacion,
                etiqueta: 'Repite la contraseña',
                ocultar: true,
                accionTeclado: TextInputAction.done,
                alEnviar: _enviar,
                validador: (v) =>
                    v != _contrasena.text ? 'Las contraseñas no coinciden' : null,
              ),
              const SizedBox(height: 16),
              BannerError(_error),
              BotonCarga(
                texto: 'Crear cuenta',
                cargando: _cargando,
                alPresionar: _enviar,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/iniciar-sesion'),
          child: const Text('¿Ya tienes cuenta? Inicia sesión'),
        ),
      ],
    );
  }
}
