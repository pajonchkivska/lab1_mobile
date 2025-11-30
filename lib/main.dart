// lib/main.dart

import 'package:flutter/material.dart';
import 'repositories/local_user_repository.dart';
import 'services/auth_service.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/profile.dart';

// Додаємо імпорт локалізацій для роботи intl з англійською
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  final userRepo = LocalUserRepository();
  final authService = AuthService(repository: userRepo);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({required this.authService, super.key});

  @override
  Widget build(BuildContext context) {
    // Спокійні та нейтральні кольори
    const Color primaryBlue = Color(0xFF455A64); 
    const Color accentLight = Color(0xFF90CAF9); 

    return MaterialApp(
      title: 'ToDo + Auth',
      // Налаштування локалізації для коректної роботи DateFormat англійською
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // Основна мова - англійська
        Locale('uk', 'UA'), // Українська (як запасний варіант)
      ],
      locale: const Locale('en', 'US'), // Встановлюємо англійську за замовчуванням
      // Стилізація (без змін)
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ).copyWith(
          secondary: accentLight,
          primary: primaryBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: primaryBlue,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(150, 44),
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accentLight, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginPage(authService: authService),
        '/register': (_) => RegisterPage(authService: authService),
        '/home': (_) => HomePage(authService: authService),
        '/profile': (_) => ProfilePage(authService: authService),
      },
    );
  }
}