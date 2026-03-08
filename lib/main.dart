import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/map/presentation/pages/map_page.dart';
import 'features/home/presentation/pages/emergencias.dart';
import 'features/home/presentation/pages/emergencia_record.dart';
import 'features/home/presentation/pages/emergency_contacts_page.dart';

void main() {
  runApp(const GuardianApp());
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/map': (context) => const MapPage(),
        '/emergencia': (context) => const EmergenciaPage(),
        '/emergencia-record': (context) => const EmergencyActivePage(),
        '/emergencia-contacs': (context) => const EmergencyContactsPage(),

      },
    );
  }
}