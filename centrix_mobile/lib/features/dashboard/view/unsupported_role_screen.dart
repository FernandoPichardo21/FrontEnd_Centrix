import 'package:flutter/material.dart';

class UnsupportedRoleScreen extends StatelessWidget {
  const UnsupportedRoleScreen({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centrix')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Tu usuario tiene un rol no reconocido: $role. '
            'Solicita apoyo al administrador.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
