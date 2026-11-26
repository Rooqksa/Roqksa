// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoqksaApp());
}

class RoqksaApp extends StatelessWidget {
  const RoqksaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const aqua = Color(0xFF27D7D0);
    const deepNavy = Color(0xFF101C2B);
    const panel = Color(0xFF192A3B);
    final scheme = ColorScheme.fromSeed(
      seedColor: aqua,
      brightness: Brightness.dark,
      surface: panel,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roqksa',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepNavy,
        colorScheme: scheme,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: deepNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF142437),
          indicatorColor: aqua.withValues(alpha: .22),
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800 : FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? aqua : Colors.white60,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) =>
            IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? aqua : Colors.white60,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: panel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: aqua, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: aqua,
            foregroundColor: const Color(0xFF09252B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
