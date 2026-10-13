import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';
import '../widgets/dialogo_confirmacion.dart';
import '../widgets/dialogo_editar_publicacion.dart';
import '../widgets/error_con_reintento.dart';
import '../widgets/mensaje_vacio.dart';
import '../widgets/pagina_acceso.dart';
import '../widgets/tarjeta_mi_publicacion.dart';

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
  /// 'disponible', 'oculto', 'no disponible'.
  Future<void> _cambiarEstado(int id, String nuevoEstado) async {
    try {
      await context
          .read<ControladorAutenticacion>()
          .cambiarEstadoPublicacion(id, nuevoEstado);
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

  /// Abre el chat de WhatsApp con el teléfono de quien reservó (Bolivia: +591).
  Future<void> _abrirWhatsapp(String telefono) async {
    final enlace = Uri.parse('https://wa.me/591$telefono');
    bool abierto = false;
    try {
      abierto = await launchUrl(enlace, mode: LaunchMode.externalApplication);
    } catch (_) {
      abierto = false;
    }
    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  /// Completa el intercambio de una publicación reservada (pide confirmación).
  /// Si no está reservada, explica por qué no se puede.
  Future<void> _completar(int id, String titulo, bool estaReservada) async {
    if (!estaReservada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solo se puede completar un intercambio de una publicación reservada. Primero debe reservarse',
          ),
        ),
      );
      return;
    }

    final acepta = await confirmarAccion(
      context,
      titulo: 'Completar intercambio',
      mensaje:
          '¿Confirmas que el intercambio de "$titulo" ya se realizó? '
          'Después no se podrá reservar, editar ni eliminar.',
      textoBoton: 'Completar',
    );
    if (!acepta || !mounted) return;

    try {
      await context.read<ControladorAutenticacion>().completarIntercambio(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Intercambio completado!')),
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
        const SnackBar(content: Text('Error al completar el intercambio')),
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
      builder: (ctx) => DialogoEditarPublicacion(
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
      contenido = ErrorConReintento(
        mensaje: _error,
        alReintentar: _cargarPublicaciones,
      );
    } else if (_publicaciones.isEmpty) {
      contenido = MensajeVacio(
        icono: Icons.inventory_2_outlined,
        titulo: 'Aún no tienes publicaciones',
        mensaje: 'Crea una publicación para intercambiar objetos con otros estudiantes.',
        textoBoton: 'Crear nueva publicación',
        alBoton: () => context.go('/publicacion'),
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
              // El teléfono solo le llega al dueño (esta es su pantalla)
              final telefonoReserva = usuarioReserva?['telefono'] as String?;
              final estaReservada = pub['estado_publicacion'] == 'reservado';
              final tituloPub = (pub['titulo'] as String?) ?? 'Sin título';

              return TarjetaMiPublicacion(
                id: idPub,
                titulo: (pub['titulo'] as String?) ?? 'Sin título',
                descripcion: pub['descripcion'] as String?,
                estado: (pub['estado'] as String?) ?? 'usado',
                categoria: (pub['categoria'] as String?) ?? 'otros',
                estadoPublicacion:
                    (pub['estado_publicacion'] as String?) ?? 'disponible',
                nombreReserva: nombreReserva,
                telefonoReserva: telefonoReserva,
                alCompletar: () => _completar(idPub, tituloPub, estaReservada),
                alAbrirWhatsapp: () => _abrirWhatsapp(telefonoReserva ?? ''),
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
