import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../componentes/comunes.dart';
import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';

/// RUTA PRIVADA ("/intercambios"): los intercambios completados de la persona,
/// ya sea como dueña del objeto o como quien lo reservó.
class PantallaIntercambios extends StatefulWidget {
  const PantallaIntercambios({super.key});

  @override
  State<PantallaIntercambios> createState() => _PantallaIntercambiosState();
}

class _PantallaIntercambiosState extends State<PantallaIntercambios> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _intercambios = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista =
          await context.read<ControladorAutenticacion>().obtenerIntercambios();
      if (!mounted) return;
      setState(() {
        _intercambios = lista;
        _cargando = false;
      });
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar tus intercambios';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final yo = context.watch<ControladorAutenticacion>().usuario;

    Widget contenido;
    if (_cargando) {
      contenido = const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_error != null) {
      contenido = Column(
        children: [
          BannerError(_error),
          FilledButton.tonal(onPressed: _cargar, child: const Text('Reintentar')),
        ],
      );
    } else if (_intercambios.isEmpty) {
      contenido = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.handshake_outlined, size: 64, color: colores.outline),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes intercambios completados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      contenido = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final pub in _intercambios) ...[
            _construirTarjeta(pub, yo?.id, colores),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return PaginaAcceso(
      titulo: 'Intercambios completados',
      anchoMaximo: 560,
      alVolver: () => context.go('/perfil'),
      acciones: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar',
          onPressed: _cargar,
        ),
      ],
      hijos: [
        contenido,
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/perfil'),
          child: const Text('Volver al perfil'),
        ),
      ],
    );
  }

  /// Una tarjeta por intercambio: el objeto y con quién se hizo.
  Widget _construirTarjeta(
    Map<String, dynamic> pub,
    int? idYo,
    ColorScheme colores,
  ) {
    final autor = pub['autor'] as Map<String, dynamic>?;
    final reserva = pub['usuario_reserva'] as Map<String, dynamic>?;
    final fueDueno = (pub['id_usuario'] as num?)?.toInt() == idYo;

    // La otra persona del intercambio
    final otra = fueDueno ? reserva : autor;
    final nombreOtra = otra?['nombre'] as String? ?? 'otra persona';
    final categoria = etiquetasCategoria[pub['categoria']] ?? 'Otros';

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (pub['titulo'] as String?) ?? 'Sin título',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              fueDueno
                  ? 'Lo entregaste a: $nombreOtra'
                  : 'Lo recibiste de: $nombreOtra',
              style: TextStyle(color: colores.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('Categoría: $categoria'),
                ),
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Intercambiado'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
