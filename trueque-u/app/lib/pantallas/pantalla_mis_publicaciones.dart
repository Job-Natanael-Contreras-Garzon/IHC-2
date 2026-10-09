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

  /// Permite al dueño alternar de modo/estado entre:
  /// 'disponible', 'reservado', 'oculto', 'no disponible'.
  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    try {
      final usuario = context.read<ControladorAutenticacion>().usuario;
      await context.read<ControladorAutenticacion>().cambiarEstadoPublicacion(
            id,
            nuevoEstado,
            idUsuario: usuario?.id,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Publicación cambiada a "$nuevoEstado"')),
      );
      _cargarPublicaciones();
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cambiar el estado')),
      );
    }
  }

  /// Función para descartar la reserva activa y regresar el objeto a 'disponible'
  Future<void> _descartarReserva(int id) async {
    try {
      await context.read<ControladorAutenticacion>().descartarReservaPublicacion(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva descartada. Publicación ahora disponible.')),
      );
      _cargarPublicaciones();
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al descartar la reserva')),
      );
    }
  }

  /// Función para editar nombre y descripción de la publicación.
  /// Si está reservada, no permite editar y muestra el mensaje explicativo.
  Future<void> _editar(
    int id,
    String tituloActual,
    String? descripcionActual,
    bool estaReservada,
  ) async {
    // Si la publicación está reservada por alguien, bloqueamos la acción y mostramos el error
    if (estaReservada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes editar una publicación que ya fue reservada'),
        ),
      );
      return;
    }

    // Abre el formulario modal para editar nombre y descripción
    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DialogoEditarPublicacion(
        id: id,
        tituloInicial: tituloActual,
        descripcionInicial: descripcionActual,
      ),
    );

    if (resultado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación actualizada correctamente')),
      );
      _cargarPublicaciones();
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
            Builder(builder: (context) {
              final idPub = (pub['id'] as num).toInt();
              final usuarioReserva = pub['usuario_reserva'] as Map<String, dynamic>?;
              final nombreReserva = usuarioReserva?['nombre'] as String?;
              final estaReservada = pub['estado_publicacion'] == 'reservado';

              return _TarjetaPublicacion(
                id: idPub,
                titulo: (pub['titulo'] as String?) ?? 'Sin título',
                descripcion: pub['descripcion'] as String?,
                estado: (pub['estado'] as String?) ?? 'usado',
                estadoPublicacion:
                    (pub['estado_publicacion'] as String?) ?? 'disponible',
                nombreReserva: nombreReserva,
                alEditar: () => _editar(
                  idPub,
                  (pub['titulo'] as String?) ?? '',
                  pub['descripcion'] as String?,
                  estaReservada,
                ),
                alEliminar: () => _eliminar(
                  idPub,
                  (pub['titulo'] as String?) ?? 'esta publicación',
                ),
                alDescartarReserva: () => _descartarReserva(idPub),
                alCambiarEstado: (nuevoEstado) => _cambiarEstado(idPub, nuevoEstado),
              );
            }),
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

/// =========================================================================
/// TARJETA DE PUBLICACIÓN PROPIA
/// =========================================================================
/// Muestra los detalles de la publicación del usuario, el estado actual,
/// quién la reservó (si aplica), un selector para cambiar de modo/estado,
/// y un botón directo para descartar la reserva si está apartada.
class _TarjetaPublicacion extends StatelessWidget {
  const _TarjetaPublicacion({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.estado,
    required this.estadoPublicacion,
    this.nombreReserva,
    required this.alEditar,
    required this.alEliminar,
    required this.alDescartarReserva,
    required this.alCambiarEstado,
  });

  final int id;
  final String titulo;
  final String? descripcion;
  final String estado;
  final String estadoPublicacion;
  final String? nombreReserva;
  final VoidCallback alEditar;
  final VoidCallback alEliminar;
  final VoidCallback alDescartarReserva;
  final ValueChanged<String> alCambiarEstado;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final estaReservada = estadoPublicacion == 'reservado';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: estaReservada
              ? colores.primary.withValues(alpha: 0.4)
              : colores.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: Título y menú de opciones (editar / cambiar estado / eliminar)
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
                // Botón lápiz para editar nombre y descripción (deshabilitado visualmente si está reservada)
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: estaReservada
                        ? colores.outline.withValues(alpha: 0.35)
                        : colores.primary,
                  ),
                  tooltip: estaReservada
                      ? 'No se puede editar: la publicación está reservada'
                      : 'Editar información',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: alEditar,
                ),
                const SizedBox(width: 8),
                // Selector de modo / estado_publicacion
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  tooltip: 'Cambiar modo / estado',
                  onSelected: alCambiarEstado,
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'disponible',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Marcar como Disponible'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reservado',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_outline, size: 18, color: Colors.amber),
                          SizedBox(width: 8),
                          Text('Marcar como Reservado'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'oculto',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_off_outlined, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('Ocultar publicación'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'no disponible',
                      child: Row(
                        children: [
                          Icon(Icons.block_outlined, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Marcar como No disponible'),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: colores.error,
                  tooltip: 'Eliminar definitivamente',
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

            // Chips con la condición del objeto y el estado de la publicación
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
                  fondo: estaReservada
                      ? Colors.amber.shade100
                      : colores.secondaryContainer,
                  colorTexto: estaReservada
                      ? Colors.amber.shade900
                      : colores.onSecondaryContainer,
                ),
                // Indicador explícito de quién reservó la publicación
                if (estaReservada)
                  _Etiqueta(
                    icono: Icons.person_pin_outlined,
                    texto: nombreReserva != null
                        ? 'Reservado por: $nombreReserva'
                        : 'Reservado por un usuario',
                    fondo: colores.tertiaryContainer,
                    colorTexto: colores.onTertiaryContainer,
                  ),
              ],
            ),

            // Si está reservada, botón directo para descartar la reserva y volver a disponible
            if (estaReservada) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Descartar reserva (volver a disponible)'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: alDescartarReserva,
                  ),
                ],
              ),
            ],
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

/// =========================================================================
/// DIÁLOGO PARA EDITAR INFORMACIÓN (SOLO NOMBRE Y DESCRIPCIÓN)
/// =========================================================================
/// Permite modificar únicamente el nombre y la descripción del objeto publicado.
/// Muestra errores de validación y respuestas de error del servidor como BannerError.
class _DialogoEditarPublicacion extends StatefulWidget {
  const _DialogoEditarPublicacion({
    required this.id,
    required this.tituloInicial,
    this.descripcionInicial,
  });

  final int id;
  final String tituloInicial;
  final String? descripcionInicial;

  @override
  State<_DialogoEditarPublicacion> createState() =>
      _DialogoEditarPublicacionState();
}

class _DialogoEditarPublicacionState extends State<_DialogoEditarPublicacion> {
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

