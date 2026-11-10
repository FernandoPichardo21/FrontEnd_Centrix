import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar Crashlytics para Android y otras plataformas nativas
  if (!kIsWeb) {
    // Capturar errores del framework de Flutter
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Capturar errores no controlados del entorno de ejecución
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      return true;
    };
  }

  runApp(const CrashlyticsTestApp());
}

/// Widget temporal para realizar pruebas controladas de Firebase Crashlytics.
class CrashlyticsTestApp extends StatefulWidget {
  const CrashlyticsTestApp({super.key});

  @override
  State<CrashlyticsTestApp> createState() => _CrashlyticsTestAppState();
}

class _CrashlyticsTestAppState extends State<CrashlyticsTestApp> {
  bool _showMainApp = false;

  @override
  Widget build(BuildContext context) {
    if (_showMainApp) {
      return const CentrixApp();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Firebase Crashlytics'),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bug_report,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prueba de Firebase Crashlytics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Al presionar el botón se forzará un cierre inesperado (crash) para enviar el reporte a la consola de Firebase.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Probar Crashlytics (Crash)'),
                  onPressed: () {
                    FirebaseCrashlytics.instance.crash();
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showMainApp = true;
                    });
                  },
                  child: const Text('Continuar a la Aplicación Principal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
