import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../componentes/comunes.dart';
import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';

class PantallaIniciarSesion extends StatefulWidget {
  const PantallaIniciarSesion({super.key});

  @override
  State<PantallaIniciarSesion> createState() => _PantallaIniciarSesionState();
}

class _PantallaIniciarSesionState extends State<PantallaIniciarSesion> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
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
          .iniciarSesion(_correo.text, _contrasena.text);
      if (!mounted) return;
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
      titulo: 'Iniciar sesión',
      hijos: [
        Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                accionTeclado: TextInputAction.done,
                alEnviar: _enviar,
                validador: (v) => (v ?? '').isEmpty ? 'Escribe tu contraseña' : null,
              ),
              const SizedBox(height: 16),
              BannerError(_error),
              BotonCarga(texto: 'Entrar', cargando: _cargando, alPresionar: _enviar),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => context.go('/recuperar-contrasena'),
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
        TextButton(
          onPressed: () => context.go('/registro'),
          child: const Text('¿No tienes cuenta? Regístrate'),
        ),
      ],
    );
  }
}
