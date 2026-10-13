import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utilidades/etiquetas.dart';
import 'chip_estado.dart';

/// =========================================================================
/// COMPONENTE CARD DEL FEED
/// =========================================================================
/// Renderiza cada tarjeta con sus datos esenciales, badges informativos y botón
/// interactivo de Reservar / Descartar.
class TarjetaFeed extends StatelessWidget {
  const TarjetaFeed({
    super.key,
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
  final String categoria; // 'libros', 'electronica',....
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
                ChipEstado(
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
                    fontWeight:
                        esMiPublicacion ? FontWeight.bold : FontWeight.normal,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colores.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    estadoFisico == 'nuevo'
                        ? 'Condición: Nuevo'
                        : 'Condición: Usado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colores.onSecondaryContainer,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
