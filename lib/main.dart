import 'package:flutter/material_ui.dart';
import 'screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoqksaApp());
}

class RoqksaApp extends StatelessWidget {
  const RoqksaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF9B72FF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roqksa',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF100D1B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
          surface: const Color(0xFF1B1729),
        ),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
