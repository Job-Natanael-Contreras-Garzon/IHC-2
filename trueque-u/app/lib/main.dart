import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'estado/controlador_autenticacion.dart';
import 'rutas.dart';
import 'servicios/cliente_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencias = await SharedPreferences.getInstance();
  final autenticacion = ControladorAutenticacion(ClienteApi(), preferencias);

  // Se restaura la sesión ANTES de mostrar la primera pantalla, para que al
  // recargar la app las rutas privadas ya sepan si hay persona o no.
  await autenticacion.restaurarSesion();

  runApp(AplicacionTruequeU(autenticacion: autenticacion));
}

class AplicacionTruequeU extends StatefulWidget {
  const AplicacionTruequeU({super.key, required this.autenticacion});

  final ControladorAutenticacion autenticacion;

  @override
  State<AplicacionTruequeU> createState() => _AplicacionTruequeUState();
}

class _AplicacionTruequeUState extends State<AplicacionTruequeU> {
  late final GoRouter _rutas = construirRutas(widget.autenticacion);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ControladorAutenticacion>.value(
      value: widget.autenticacion,
      child: MaterialApp.router(
        title: 'Trueque U',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
          useMaterial3: true,
        ),
        routerConfig: _rutas,
      ),
    );
  }
}
