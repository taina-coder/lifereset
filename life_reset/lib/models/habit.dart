import 'task.dart';

// Classe auxiliar para os badges de benefícios do card
class HabitBenefit {
  final String label;
  final int bonusValue;
  final String iconType;

  HabitBenefit({
    required this.label,
    required this.bonusValue,
    required this.iconType,
  });

  factory HabitBenefit.fromJson(Map<String, dynamic> json) {
    return HabitBenefit(
      label: json['label'] ?? '',
      bonusValue: json['bonusValue'] ?? 0,
      iconType: json['iconType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'bonusValue': bonusValue,
    'iconType': iconType,
  };
}

class Habit {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String? imageUrl;
  final String? goalDescription;
  final String? scientificStudy;
  final int? fitPercentage;
  final List<HabitBenefit> benefits;
  List<Task> tasks;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    this.imageUrl,
    this.goalDescription,
    this.scientificStudy,
    this.fitPercentage,
    this.benefits = const [],
    required this.tasks,
  });

  // LOGICA CORRIGIDA: Agora o progresso é baseado no XP acumulado, não na contagem
  double get dayProgress {
    if (tasks.isEmpty) return 0.0;

    // Se for o cronograma de 30 dias, o XP total alvo é 100
    // Somamos o xpValue apenas das tarefas marcadas como concluídas
    double completedXP = tasks
        .where((t) => t.isCompleted)
        .fold(0.0, (sum, t) => sum + t.xpValue);

    // O progresso é o XP ganho dividido por 100 (valor total do nível/hábito)
    double progress = completedXP / 100.0;
    
    return progress > 1.0 ? 1.0 : progress; // Trava em 100%
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      imageUrl: json['imageUrl'],
      goalDescription: json['goalDescription'],
      scientificStudy: json['scientificStudy'],
      fitPercentage: json['fitPercentage'],
      benefits: (json['benefits'] as List? ?? [])
          .map((b) => HabitBenefit.fromJson(b))
          .toList(),
      tasks: (json['tasks'] as List? ?? [])
          .map((t) => Task.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'duration': duration,
      'imageUrl': imageUrl,
      'goalDescription': goalDescription,
      'scientificStudy': scientificStudy,
      'fitPercentage': fitPercentage,
      'benefits': benefits.map((b) => b.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }
}