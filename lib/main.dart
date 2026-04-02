import 'package:flutter/material.dart';
import 'utils/router.dart';

void main() {
  runApp(const ArtiselleApp());
}

class ArtiselleApp extends StatelessWidget {
  const ArtiselleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artiselle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F5F5),
        ),
      ),
      onGenerateRoute: generateRoute,
      initialRoute: AppRoutes.login,
    );
  }
}
