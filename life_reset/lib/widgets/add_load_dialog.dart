import 'package:flutter/material.dart';
import '../services/habit_service.dart';

Future<void> showAddLoadDialog(BuildContext context, String exerciseName) async {
  final TextEditingController weightController = TextEditingController();

  // Cores baseadas na sua paleta do HomeScreen para manter o padrão visual
  const Color colorAccent = Color(0xFFD0FF00);
  const Color colorPrimary = Color(0xFF8116E0);
  const Color colorSurface = Color(0xFF121212);

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        title: Text(
          'ANOTAR CARGA\n$exerciseName',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: colorAccent, 
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5
          ),
        ),
        content: TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: colorAccent,
          decoration: InputDecoration(
            labelText: 'Peso (kg)',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            hintText: 'Ex: 40.5',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            suffixText: 'kg',
            suffixStyle: const TextStyle(color: colorAccent, fontWeight: FontWeight.bold),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: colorAccent),
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCELAR', 
              style: TextStyle(color: Colors.white.withOpacity(0.5), letterSpacing: 1)
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorAccent.withOpacity(0.1),
              foregroundColor: colorAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorAccent.withOpacity(0.5)),
              ),
            ),
            onPressed: () {
              // Troca vírgula por ponto para evitar erro de conversão
              final weight = double.tryParse(weightController.text.replaceAll(',', '.'));
              
              if (weight != null) {
                // Chama o HabitService para salvar a carga
                HabitService.addExerciseLoad(exerciseName, weight);
                
                // Fecha o pop-up
                Navigator.pop(context); 
                
                // Mostra um aviso de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Carga registrada com sucesso!', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: colorPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: const Text('SALVAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      );
    },
  );
}