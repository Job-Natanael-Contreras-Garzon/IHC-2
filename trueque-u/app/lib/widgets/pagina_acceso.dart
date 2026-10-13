import 'package:flutter/material.dart';

/// Pantalla de acceso: barra superior + contenido centrado y con scroll.
class PaginaAcceso extends StatelessWidget {
  const PaginaAcceso({
    super.key,
    required this.titulo,
    required this.hijos,
    this.alVolver,
    this.acciones,
    this.anchoMaximo = 420,
    this.botonFlotante,
  });

  final String titulo;
  final List<Widget> hijos;
  final VoidCallback? alVolver;
  final List<Widget>? acciones;
  final double anchoMaximo;
  final Widget? botonFlotante;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        automaticallyImplyLeading: false,
        leading: alVolver != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: alVolver,
              )
            : null,
        actions: acciones,
      ),
      floatingActionButton: botonFlotante,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: anchoMaximo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: hijos,
            ),
          ),
        ),
      ),
    );
  }
}
