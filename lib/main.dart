import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verifica se o player já existe no sistema
  final bool hasPlayer = await StorageService.hasPlayer();
  
  runApp(LifeResetApp(startWithOnboarding: !hasPlayer));
}

class LifeResetApp extends StatelessWidget {
  final bool startWithOnboarding; // Campo obrigatório adicionado

  const LifeResetApp({super.key, required this.startWithOnboarding});

  @override
  Widget build(BuildContext context) {
    const Color colorPrimary = Color(0xFF8116E0);
    const Color colorAccent = Color(0xFFD0FF00);
    // ignore: unused_local_variable
    const Color colorText = Color(0xFFFEFFFC);

    return MaterialApp(
      title: 'LIFE RESET',
      debugShowCheckedModeBanner: false,
      
      // Define a rota inicial baseada no Onboarding
      initialRoute: startWithOnboarding ? '/onboarding' : '/home',
      
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: colorPrimary,
          secondary: colorAccent,
          surface: Color(0xFF121212),
        ),
        // ... (resto do seu TextTheme e AppBarTheme mantidos)
      ),
    );
  }
}