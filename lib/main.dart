import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'utils/router.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ArtiselleApp());
}

class ArtiselleApp extends StatelessWidget {
  const ArtiselleApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return MaterialApp(
      title: 'Artiselle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EFF),
          brightness: Brightness.light,
          surface: const Color(0xFFF0EDE8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0EDE8),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFE8E4DF),
        ),
      ),
      onGenerateRoute: generateRoute,
      initialRoute: AppRoutes.login,
    );
  }
}
