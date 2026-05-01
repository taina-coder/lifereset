import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Adicionado
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/goal_selection_screen.dart'; // Adicionado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verifica se o player já existe no sistema
  final bool hasPlayer = await StorageService.hasPlayer();
  
  // Verifica se os protocolos já foram escolhidos no SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool hasSelectedProtocol = prefs.getBool('hasSelectedProtocol') ?? false;
  
  // Define a rota inicial baseada no status do jogador
  String initialRoute;
  if (!hasPlayer) {
    initialRoute = '/onboarding'; // Primeiro acesso: cria o perfil
  } else if (!hasSelectedProtocol) {
    initialRoute = '/protocols'; // Perfil criado, mas protocolos não selecionados
  } else {
    initialRoute = '/home'; // Tudo pronto, vai pra home
  }

  runApp(LifeResetApp(initialRoute: initialRoute));
}

class LifeResetApp extends StatelessWidget {
  final String initialRoute; // Alterado para receber a string da rota inicial

  const LifeResetApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    const Color colorPrimary = Color(0xFFD0FF00);
    const Color colorAccent = Color(0xFF8116E0);
    // ignore: unused_local_variable
    const Color colorText = Color(0xFFFEFFFC);

    return MaterialApp(
      title: 'LIFE RESET',
      debugShowCheckedModeBanner: false,
      
      // Define a rota inicial calculada na função main
      initialRoute: initialRoute,
      
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/protocols': (context) => const GoalSelectionScreen(), // Rota da tela de protocolos adicionada
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