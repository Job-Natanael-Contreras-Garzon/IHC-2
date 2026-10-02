import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../componentes/comunes.dart';
import '../estado/controlador_autenticacion.dart';

/// RUTA PRIVADA ("/perfil"): sin sesión, el router redirige a "/iniciar-sesion".
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<ControladorAutenticacion>().usuario;
    // Al cerrar sesión, el router tarda un instante en redirigir.
    if (usuario == null) return const SizedBox.shrink();

    return PaginaAcceso(
      titulo: 'Mi perfil',
      hijos: [
        Text(
          'Hola, ${usuario.nombre}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => context.go('/cambiar-contrasena'),
          child: const Text('Cambiar contraseña'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => context.go('/publicacion'),
          child: const Text('Crear nueva publicación'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go('/mis-publicaciones'),
          child: const Text('Ver mis publicaciones'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          // Al cerrar la sesión, el router redirige solo al inicio de sesión.
          onPressed: () => context.read<ControladorAutenticacion>().cerrarSesion(),
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
