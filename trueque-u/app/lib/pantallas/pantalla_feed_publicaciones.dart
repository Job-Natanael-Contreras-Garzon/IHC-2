import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../componentes/comunes.dart';
import '../estado/controlador_autenticacion.dart';
import '../servicios/cliente_api.dart';

/// =========================================================================
/// PANTALLA FEED DE PUBLICACIONES (VISTA EN CUADRÍCULA / GRID)
/// =========================================================================
/// Muestra todas las publicaciones del sistema en una cuadrícula responsiva.
/// Permite a cualquier usuario explorar ofertas de trueque, ver el estado
/// de cada artículo, buscar por título, filtrar, reservar, descartar reservas
/// y completar intercambios.
class PantallaFeedPublicaciones extends StatefulWidget {
  const PantallaFeedPublicaciones({super.key});

  @override
  State<PantallaFeedPublicaciones> createState() =>
      _PantallaFeedPublicacionesState();
}

class _PantallaFeedPublicacionesState extends State<PantallaFeedPublicaciones> {
  // Estados para control de carga y errores
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _publicaciones = [];

  // Búsqueda y filtros (null = sin filtro)
  final _buscarCtrl = TextEditingController();
  String _busqueda = ''; // texto de búsqueda que ya se aplicó
  String? _categoria;
  String? _condicion;
  String? _disponibilidad;

  bool get _hayFiltros =>
      _busqueda.isNotEmpty ||
      _categoria != null ||
      _condicion != null ||
      _disponibilidad != null;

  // Almacena los IDs de publicaciones que tienen una acción en proceso (para mostrar spinner en el botón)
  final Set<int> _accionesEnProgreso = {};

  @override
  void initState() {
    super.initState();
    _cargarPublicaciones();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  /// Cambia un filtro y vuelve a pedir las publicaciones
  void _aplicarFiltro(VoidCallback cambio) {
    setState(cambio);
    _cargarPublicaciones();
  }

  /// Aplica el texto escrito en el buscador
  void _buscar() => _aplicarFiltro(() => _busqueda = _buscarCtrl.text.trim());

  /// Quita todos los filtros y la búsqueda
  void _quitarFiltros() {
    _buscarCtrl.clear();
    _aplicarFiltro(() {
      _busqueda = '';
      _categoria = null;
      _condicion = null;
      _disponibilidad = null;
    });
  }

  /// Carga o recarga la lista de publicaciones desde el backend
  Future<void> _cargarPublicaciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = await context
          .read<ControladorAutenticacion>()
          .obtenerPublicacionesFeed(
            buscar: _busqueda,
            categoria: _categoria,
            condicion: _condicion,
            disponibilidad: _disponibilidad,
          );
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
        _error = 'No se pudieron cargar las publicaciones del feed';
        _cargando = false;
      });
    }
  }

  /// LÓGICA DE RESERVAR:
  /// Envía la petición PUT /api/publicaciones/:id/reservado (el servidor usa la sesión)
  Future<void> _reservar(int idPublicacion) async {
    final auth = context.read<ControladorAutenticacion>();
    // Solo se reserva con la sesión iniciada
    if (auth.usuario == null) return;

    setState(() => _accionesEnProgreso.add(idPublicacion));

    try {
      await auth.reservarPublicacion(idPublicacion);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Publicación reservada exitosamente!')),
      );
      // Recarga el feed para actualizar la información de la card
      await _cargarPublicaciones();
    } on ExcepcionApi catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al reservar la publicación')),
      );
    } finally {
      if (mounted) {
        setState(() => _accionesEnProgreso.remove(idPublicacion));
      }
    }
  }

  /// LÓGICA DE DESCARTAR RESERVA:
  /// Envía la petición PUT /api/publicaciones/:id/disponible para liberar la publicación
  Future<void> _descartarReserva(int idPublicacion) async {
    final auth = context.read<ControladorAutenticacion>();

    setState(() => _accionesEnProgreso.add(idPublicacion));

    try {
      await auth.descartarReservaPublicacion(idPublicacion);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva descartada. Publicación nuevamente disponible.')),
      );
      // Recarga el feed para reflejar el estado disponible
      await _cargarPublicaciones();
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
    } finally {
      if (mounted) {
        setState(() => _accionesEnProgreso.remove(idPublicacion));
      }
    }
  }

  /// LÓGICA DE COMPLETAR EL INTERCAMBIO:
  /// Pide confirmación y envía PUT /api/publicaciones/:id/intercambiado
  Future<void> _completar(int idPublicacion, String titulo) async {
    final auth = context.read<ControladorAutenticacion>();

    final acepta = await confirmarAccion(
      context,
      titulo: 'Completar intercambio',
      mensaje:
          '¿Confirmas que el intercambio de "$titulo" ya se realizó? '
          'Después no se podrá reservar, editar ni eliminar.',
      textoBoton: 'Completar',
    );
    if (!acepta || !mounted) return;

    setState(() => _accionesEnProgreso.add(idPublicacion));

    try {
      await auth.completarIntercambio(idPublicacion);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Intercambio completado!')),
      );
      await _cargarPublicaciones();
    } on ExcepcionApi catch (e) {
      // Si no se puede, el servidor explica el motivo
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al completar el intercambio')),
      );
    } finally {
      if (mounted) {
        setState(() => _accionesEnProgreso.remove(idPublicacion));
      }
    }
  }

  /// Botón de menú para un filtro (categoría, condición o disponibilidad)
  Widget _menuFiltro(
    String titulo,
    Map<String, String> opciones,
    void Function(String) alElegir,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'Filtrar por ${titulo.toLowerCase()}',
      onSelected: alElegir,
      itemBuilder: (ctx) => [
        for (final opcion in opciones.entries)
          PopupMenuItem<String>(value: opcion.key, child: Text(opcion.value)),
      ],
      child: Chip(
        avatar: const Icon(Icons.filter_list, size: 16),
        label: Text(titulo),
      ),
    );
  }

  /// Buscador + filtros + lista de filtros activos (se pueden quitar)
  Widget _construirFiltros() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _buscarCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _buscar(),
                decoration: InputDecoration(
                  hintText: 'Buscar por título',
                  isDense: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: 'Buscar',
                    onPressed: _buscar,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _menuFiltro(
                    'Categoría',
                    etiquetasCategoria,
                    (v) => _aplicarFiltro(() => _categoria = v),
                  ),
                  _menuFiltro(
                    'Condición',
                    etiquetasCondicion,
                    (v) => _aplicarFiltro(() => _condicion = v),
                  ),
                  _menuFiltro(
                    'Disponibilidad',
                    etiquetasDisponibilidad,
                    (v) => _aplicarFiltro(() => _disponibilidad = v),
                  ),
                ],
              ),
              // Filtros activos: cada uno se puede quitar con la X
              if (_hayFiltros) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_busqueda.isNotEmpty)
                      InputChip(
                        label: Text('Título: $_busqueda'),
                        onDeleted: () {
                          _buscarCtrl.clear();
                          _aplicarFiltro(() => _busqueda = '');
                        },
                      ),
                    if (_categoria != null)
                      InputChip(
                        label: Text('Categoría: ${etiquetasCategoria[_categoria]}'),
                        onDeleted: () => _aplicarFiltro(() => _categoria = null),
                      ),
                    if (_condicion != null)
                      InputChip(
                        label: Text('Condición: ${etiquetasCondicion[_condicion]}'),
                        onDeleted: () => _aplicarFiltro(() => _condicion = null),
                      ),
                    if (_disponibilidad != null)
                      InputChip(
                        label: Text(
                          'Disponibilidad: ${etiquetasDisponibilidad[_disponibilidad]}',
                        ),
                        onDeleted: () =>
                            _aplicarFiltro(() => _disponibilidad = null),
                      ),
                    TextButton(
                      onPressed: _quitarFiltros,
                      child: const Text('Quitar todos'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final usuarioActual = context.watch<ControladorAutenticacion>().usuario;

    Widget cuerpo;

    if (_cargando) {
      cuerpo = const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_error != null) {
      cuerpo = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BannerError(_error),
                FilledButton.tonal(
                  onPressed: _cargarPublicaciones,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_publicaciones.isEmpty && _hayFiltros) {
      // Hay filtros activos pero nada coincide
      cuerpo = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: colores.outline),
                const SizedBox(height: 16),
                const Text(
                  'Ninguna publicación coincide con tu búsqueda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _quitarFiltros,
                  child: const Text('Quitar filtros'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_publicaciones.isEmpty) {
      cuerpo = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed_outlined, size: 64, color: colores.outline),
                const SizedBox(height: 16),
                const Text(
                  'No hay publicaciones disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sé el primero en compartir un objeto para intercambiar con la comunidad.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/publicacion'),
                  child: const Text('Crear publicación'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      cuerpo = LayoutBuilder(
        builder: (context, constraints) {
          // Calcula el número de columnas para la cuadrícula en base al ancho disponible
          final anchoTotal = constraints.maxWidth;
          final int columnas = anchoTotal > 900
              ? 3
              : (anchoTotal > 600 ? 2 : 1);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // Relación de aspecto adaptada para acomodar título, descripción y botones
                  mainAxisExtent: 330,
                ),
                itemCount: _publicaciones.length,
                itemBuilder: (context, index) {
                  final pub = _publicaciones[index];
                  final id = (pub['id'] as num).toInt();
                  final idAutor = (pub['id_usuario'] as num?)?.toInt();
                  final idReserva = (pub['id_usuario_reserva'] as num?)?.toInt();

                  // Extracción de datos del autor y de quién reservó
                  final autor = pub['autor'] as Map<String, dynamic>?;
                  final usuarioReserva = pub['usuario_reserva'] as Map<String, dynamic>?;

                  final nombreAutor = autor?['nombre'] as String? ?? 'Usuario';
                  final nombreReserva = usuarioReserva?['nombre'] as String?;

                  final estaReservado = pub['estado_publicacion'] == 'reservado';
                  final tituloPub = (pub['titulo'] as String?) ?? 'Sin título';
                  final loReserveYo =
                      usuarioActual != null && idReserva == usuarioActual.id;
                  final esMiPublicacion =
                      usuarioActual != null && idAutor == usuarioActual.id;
                  final enProgreso = _accionesEnProgreso.contains(id);

                  return _TarjetaFeed(
                    id: id,
                    titulo: tituloPub,
                    descripcion: pub['descripcion'] as String?,
                    estadoFisico: (pub['estado'] as String?) ?? 'usado',
                    categoria: (pub['categoria'] as String?) ?? 'otros',
                    estadoPublicacion:
                        (pub['estado_publicacion'] as String?) ?? 'disponible',
                    nombreAutor: nombreAutor,
                    nombreReserva: nombreReserva,
                    estaReservado: estaReservado,
                    loReserveYo: loReserveYo,
                    esMiPublicacion: esMiPublicacion,
                    enProgreso: enProgreso,
                    alReservar: () => _reservar(id),
                    alDescartar: () => _descartarReserva(id),
                    alCompletar: () => _completar(id, tituloPub),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver al perfil',
          onPressed: () => context.go('/perfil'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar feed',
            onPressed: _cargarPublicaciones,
          ),
        ],
      ),
      // Arriba el buscador y los filtros; abajo la lista
      body: Column(
        children: [
          _construirFiltros(),
          Expanded(child: cuerpo),
        ],
      ),
    );
  }
}

/// =========================================================================
/// COMPONENTE CARD DEL FEED
/// =========================================================================
/// Renderiza cada tarjeta con sus datos esenciales, badges informativos y botón
/// interactivo de Reservar / Descartar.
class _TarjetaFeed extends StatelessWidget {
  const _TarjetaFeed({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.estadoFisico,
    required this.categoria,
    required this.estadoPublicacion,
    required this.nombreAutor,
    this.nombreReserva,
    required this.estaReservado,
    required this.loReserveYo,
    required this.esMiPublicacion,
    required this.enProgreso,
    required this.alReservar,
    required this.alDescartar,
    required this.alCompletar,
  });

  final int id;
  final String titulo;
  final String? descripcion;
  final String estadoFisico; // 'nuevo' o 'usado'
  final String categoria; // 'libros', 'electronica', 'ropa' u 'otros'
  final String estadoPublicacion; // 'disponible', 'reservado', etc.
  final String nombreAutor;
  final String? nombreReserva;
  final bool estaReservado;
  final bool loReserveYo;
  final bool esMiPublicacion;
  final bool enProgreso;
  final VoidCallback alReservar;
  final VoidCallback alDescartar;
  final VoidCallback alCompletar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: loReserveYo
              ? colores.primary.withValues(alpha: 0.5)
              : colores.outlineVariant,
          width: loReserveYo ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Título del objeto y Chip de estado de publicación
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ChipEstado(
                  estado: estadoPublicacion,
                  loReserveYo: loReserveYo,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Autor de la publicación
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: colores.outline),
                const SizedBox(width: 4),
                Text(
                  esMiPublicacion ? 'Publicado por ti' : 'Por: $nombreAutor',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: esMiPublicacion ? FontWeight.bold : FontWeight.normal,
                    color: esMiPublicacion ? colores.primary : colores.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Descripción del objeto
            Expanded(
              child: Text(
                (descripcion != null && descripcion!.trim().isNotEmpty)
                    ? descripcion!
                    : 'Sin descripción detallada',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: (descripcion != null && descripcion!.trim().isNotEmpty)
                      ? colores.onSurfaceVariant
                      : colores.outline,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Chips de estado del objeto e información de reserva si aplica
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colores.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    estadoFisico == 'nuevo' ? 'Condición: Nuevo' : 'Condición: Usado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colores.onSecondaryContainer,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colores.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Categoría: ${etiquetasCategoria[categoria] ?? 'Otros'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colores.onSecondaryContainer,
                    ),
                  ),
                ),
                // Muestra qué usuario reservó el objeto si está en estado reservado
                if (estaReservado && nombreReserva != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: loReserveYo
                          ? colores.primaryContainer
                          : colores.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loReserveYo
                          ? 'Reservado por ti'
                          : 'Reservado por: $nombreReserva',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: loReserveYo
                            ? colores.onPrimaryContainer
                            : colores.onTertiaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // BOTÓN DE ACCIÓN: Reservar / Descartar
            SizedBox(
              width: double.infinity,
              child: _construirBotonAccion(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón interactivo según el estado de la reserva y el usuario
  Widget _construirBotonAccion(BuildContext context) {
    // final colores = Theme.of(context).colorScheme; // se usaba en "Descartar reserva"

    // Si hay una operación asíncrona en curso en esta card
    if (enProgreso) {
      return const Center(
        child: SizedBox(
          height: 36,
          width: 36,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Intercambio ya completado: no se puede hacer nada más
    if (estadoPublicacion == 'intercambiado') {
      return const FilledButton.tonal(
        onPressed: null,
        child: Text('Intercambio completado'),
      );
    }

    // Caso 1: Reservada por el usuario actual -> "Completar intercambio"
    // (la opción de descartar la reserva está comentada por ahora)
    if (estaReservado && loReserveYo) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.handshake_outlined, size: 18),
            label: const Text('Completar intercambio'),
            onPressed: alCompletar,
          ),
          // const SizedBox(height: 6),
          // OutlinedButton.icon(
          //   icon: const Icon(Icons.close, size: 18),
          //   label: const Text('Descartar reserva'),
          //   style: OutlinedButton.styleFrom(
          //     foregroundColor: colores.error,
          //     side: BorderSide(color: colores.error),
          //   ),
          //   onPressed: alDescartar,
          // ),
        ],
      );
    }

    // Caso 2: Reservada y es mi publicación -> el dueño puede completar el intercambio
    if (estaReservado && esMiPublicacion) {
      return FilledButton.icon(
        icon: const Icon(Icons.handshake_outlined, size: 18),
        label: const Text('Completar intercambio'),
        onPressed: alCompletar,
      );
    }

    // Caso 2b: Reservada por otra persona -> Botón deshabilitado
    if (estaReservado) {
      return FilledButton.tonal(
        onPressed: null,
        child: Text(
          nombreReserva != null ? 'Reservado ($nombreReserva)' : 'Reservado',
        ),
      );
    }

    // Caso 3: Es la propia publicación del usuario y está disponible
    if (esMiPublicacion) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.edit_outlined, size: 16),
        label: const Text('Tu publicación (Ver en mis pubs)'),
        onPressed: () => context.go('/mis-publicaciones'),
      );
    }

    // Caso 4: Publicación disponible de otro usuario -> Botón "Reservar"
    return FilledButton.icon(
      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
      label: const Text('Reservar'),
      onPressed: alReservar,
    );
  }
}

/// Etiqueta visual pequeña que indica el estado actual de la publicación
class _ChipEstado extends StatelessWidget {
  const _ChipEstado({
    required this.estado,
    required this.loReserveYo,
  });

  final String estado;
  final bool loReserveYo;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    Color fondo;
    Color texto;
    String etiqueta;

    switch (estado) {
      case 'disponible':
        fondo = Colors.green.shade100;
        texto = Colors.green.shade900;
        etiqueta = 'Disponible';
        break;
      case 'reservado':
        fondo = loReserveYo ? colores.primaryContainer : Colors.amber.shade100;
        texto = loReserveYo ? colores.onPrimaryContainer : Colors.amber.shade900;
        etiqueta = loReserveYo ? 'Reservado por ti' : 'Reservado';
        break;
      case 'intercambiado':
        fondo = Colors.blue.shade100;
        texto = Colors.blue.shade900;
        etiqueta = 'Intercambiado';
        break;
      case 'no disponible':
        fondo = Colors.grey.shade200;
        texto = Colors.grey.shade700;
        etiqueta = 'No disponible';
        break;
      default:
        fondo = colores.surfaceContainerHighest;
        texto = colores.onSurfaceVariant;
        etiqueta = estado;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        etiqueta,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
      ),
    );
  }
}
