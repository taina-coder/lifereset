import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/player.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _age = 21;
  String _gender = 'Feminino';

  final Color colorAccent = const Color(0xFFD0FF00);
  final Color colorPrimary = const Color(0xFF8116E0);

  // MÉTODO CORRIGIDO: Usa o novo contrato do Player e Storage
  void _finishOnboarding() async {
    String name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("POR FAVOR, INSIRA SEU NOME PARA INICIAR.")),
      );
      return;
    }

    // Cria o objeto Player com TODOS os campos exigidos pelo modelo atualizado
    final newPlayer = Player(
      name: name,
      age: _age,
      gender: _gender,
      level: 1, // Começa no nível 1
      xp: 0,    // Começa com 0 XP
    );

    // Salva usando o método que acabamos de criar no StorageService
    await StorageService.savePlayer(newPlayer);
    
    if (mounted) {
      // Navega para a Home e limpa a pilha de telas
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView( // Evita erro de overflow com o teclado
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("NOVO PROTOCOLO", style: TextStyle(color: colorAccent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3)),
              const Text("IDENTIFIQUE-SE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 40),

              // CAMPO DE NOME
              TextField(
                controller: _nameController,
                decoration: _inputStyle("NOME DO AGENTE"),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 40),

              // SELEÇÃO DE IDADE
              Text("IDADE: $_age ANOS", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60)),
              Slider(
                value: _age.toDouble(),
                min: 10, max: 80,
                activeColor: colorAccent,
                inactiveColor: Colors.white10,
                onChanged: (val) => setState(() => _age = val.toInt()),
              ),
              const SizedBox(height: 30),

              // SELEÇÃO DE GÊNERO
              const Text("GÊNERO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["Masculino", "Feminino", "Outro"].map((g) => _buildGenderBtn(g)).toList(),
              ),

              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent, 
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _finishOnboarding,
                  child: const Text("INICIAR SINCRONIZAÇÃO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderBtn(String label) {
    bool isSelected = _gender == label;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer( // Feedback visual suave
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? colorAccent : Colors.white10),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? colorAccent.withOpacity(0.1) : Colors.transparent,
        ),
        child: Text(label, style: TextStyle(color: isSelected ? colorAccent : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white24, fontSize: 12),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorAccent)),
    );
  }
}