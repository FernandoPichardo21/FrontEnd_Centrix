import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'config/api_config.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/viewmodel/login_viewmodel.dart';

void main() {
  final authRepository = AuthRepositoryImpl(
    client: http.Client(),
    baseUrl: ApiConfig.baseUrl,
  );

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
      routes: {
        '/login': (_) => const LoginScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
