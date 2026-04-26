// lib/models/progress_record.dart

class ProgressRecord {
  final String habitId;
  final DateTime timestamp;
  final bool completed;

  ProgressRecord({
    required this.habitId,
    required this.timestamp,
    required this.completed,
  });

  // Converte para JSON para podermos salvar no SharedPreferences
  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'timestamp': timestamp.toIso8601String(),
        'completed': completed,
      };

  // Reconstrói o objeto a partir do JSON salvo (com blindagem contra erros nulos)
  factory ProgressRecord.fromJson(Map<String, dynamic> json) => ProgressRecord(
        habitId: json['habitId'] ?? '',
        // Se a data vier nula por algum erro de gravação, usamos a data atual como plano B
        timestamp: json['timestamp'] != null 
            ? DateTime.parse(json['timestamp']) 
            : DateTime.now(),
        completed: json['completed'] ?? false,
      );
}