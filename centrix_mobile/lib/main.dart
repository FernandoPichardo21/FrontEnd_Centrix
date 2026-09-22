import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/login_viewmodel.dart';

void main() {
  // Dependency Injection setup
  final httpClient = http.Client();
  final authRepository = AuthRepositoryImpl(client: httpClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(authRepository),
        ),
      ],
      child: const CentrixApp(),
    ),
  );
}

class CentrixApp extends StatelessWidget {
  const CentrixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centrix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Assuming Inter or similar sans-serif font
      ),
      home: const LoginScreen(),
    );
  }
}
