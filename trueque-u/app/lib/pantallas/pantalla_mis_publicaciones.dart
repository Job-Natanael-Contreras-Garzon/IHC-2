import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../componentes/comunes.dart';
import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';

/// Pantalla que lista las publicaciones del usuario en formato de tarjetas.
class PantallaMisPublicaciones extends StatefulWidget {
  const PantallaMisPublicaciones({super.key});

  @override
  State<PantallaMisPublicaciones> createState() =>
      _PantallaMisPublicacionesState();
}

class _PantallaMisPublicacionesState extends State<PantallaMisPublicaciones> {
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _publicaciones = [];

  @override
  void initState() {
    super.initState();
    _cargarPublicaciones();
  }

  Future<void> _cargarPublicaciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista =
          await context.read<ControladorAutenticacion>().obtenerMisPublicaciones();
      if (!mounted) return;
      setState(() {
        _publicaciones = lista;
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
        _error = 'No se pudieron cargar tus publicaciones';
        _cargando = false;
      });
    }
  }

  Future<void> _eliminar(int id, String titulo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: Text('¿Deseas eliminar "$titulo"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await context.read<ControladorAutenticacion>().eliminarPublicacion(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación eliminada')),
      );
      _cargarPublicaciones();
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    Widget contenido;
    if (_cargando) {
      contenido = const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_error != null) {
      contenido = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            BannerError(_error),
            FilledButton.tonal(
              onPressed: _cargarPublicaciones,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    } else if (_publicaciones.isEmpty) {
      contenido = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: colores.outline),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes publicaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea una publicación para intercambiar objetos con otros estudiantes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/publicacion'),
              child: const Text('Crear nueva publicación'),
            ),
          ],
        ),
      );
    } else {
      contenido = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${_publicaciones.length}',
                style: TextStyle(color: colores.onSurfaceVariant),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva publicación'),
                onPressed: () => context.go('/publicacion'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final pub in _publicaciones) ...[
            _TarjetaPublicacion(
              id: (pub['id'] as num).toInt(),
              titulo: (pub['titulo'] as String?) ?? 'Sin título',
              descripcion: pub['descripcion'] as String?,
              estado: (pub['estado'] as String?) ?? 'usado',
              estadoPublicacion:
                  (pub['estado_publicacion'] as String?) ?? 'disponible',
              alEliminar: () => _eliminar(
                (pub['id'] as num).toInt(),
                (pub['titulo'] as String?) ?? 'esta publicación',
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return PaginaAcceso(
      titulo: 'Mis publicaciones',
      anchoMaximo: 560,
      alVolver: () => context.go('/perfil'),
      acciones: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Actualizar',
          onPressed: _cargarPublicaciones,
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
}

class _TarjetaPublicacion extends StatelessWidget {
  const _TarjetaPublicacion({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.estado,
    required this.estadoPublicacion,
    required this.alEliminar,
  });

  final int id;
  final String titulo;
  final String? descripcion;
  final String estado;
  final String estadoPublicacion;
  final VoidCallback alEliminar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colores.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: colores.error,
                  tooltip: 'Eliminar',
                  onPressed: alEliminar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (descripcion != null && descripcion!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                descripcion!,
                style: TextStyle(
                  fontSize: 14,
                  color: colores.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Etiqueta(
                  icono: Icons.label_outline,
                  texto: estado == 'nuevo' ? 'Nuevo' : 'Usado',
                  fondo: colores.primaryContainer,
                  colorTexto: colores.onPrimaryContainer,
                ),
                _Etiqueta(
                  icono: Icons.info_outline,
                  texto: _formatearEstadoPublicacion(estadoPublicacion),
                  fondo: colores.secondaryContainer,
                  colorTexto: colores.onSecondaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearEstadoPublicacion(String valor) {
    switch (valor) {
      case 'disponible':
        return 'Disponible';
      case 'reservado':
        return 'Reservado';
      case 'oculto':
        return 'Oculto';
      case 'no disponible':
        return 'No disponible';
      default:
        return valor;
    }
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.icono,
    required this.texto,
    required this.fondo,
    required this.colorTexto,
  });

  final IconData icono;
  final String texto;
  final Color fondo;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: colorTexto),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorTexto,
            ),
          ),
        ],
      ),
    );
  }
}
