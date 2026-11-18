import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AirMonitorApp());
}

class AirMonitorApp extends StatelessWidget {
  const AirMonitorApp({super.key});

  static const Color primaryColor = Color(0xFF0087CD);
  static const Color darkTextColor = Color(0xFF111827);
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color borderColor = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sledování kvality ovzduší',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: const Color(0xFF1EA2E9),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 1),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: borderColor),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
