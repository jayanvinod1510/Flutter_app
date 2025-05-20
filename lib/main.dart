import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/frappe_auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const frappeUrl = String.fromEnvironment('FRAPPE_URL',
        defaultValue: 'http://localhost:86');

    final authService = FrappeAuthService(baseUrl: frappeUrl);

    return MaterialApp(
      title: 'Medical Appointments',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Ubuntu',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
          background: Colors.white,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w700),
          displayMedium:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w700),
          displaySmall:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w700),
          headlineLarge:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w700),
          headlineMedium:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w700),
          headlineSmall:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
          titleLarge:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
          titleMedium:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
          bodyLarge:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w400),
          bodyMedium:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w400),
          bodySmall:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w400),
          labelLarge:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
          labelMedium:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
          labelSmall:
              TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w400,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 1,
          height: 64,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: const Color(0xFF4F46E5).withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(
                color: Color(0xFF4F46E5),
                size: 24,
              );
            }
            return IconThemeData(
              color: Colors.grey.shade600,
              size: 24,
            );
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4F46E5),
              );
            }
            return TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            );
          }),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(authService: authService),
        '/home': (context) => HomeScreen(
              frappeUrl: frappeUrl,
              authService: authService,
            ),
      },
    );
  }
}
