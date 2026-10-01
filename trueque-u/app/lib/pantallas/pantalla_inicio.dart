import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../componentes/comunes.dart';

/// RUTA PÚBLICA ("/"): se abre sin iniciar sesión.
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginaAcceso(
      titulo: 'Trueque U',
      hijos: [
        Text(
          'Trueque U',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Intercambia objetos y materiales con otros estudiantes.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => context.go('/iniciar-sesion'),
          child: const Text('Iniciar sesión'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go('/registro'),
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }
}
