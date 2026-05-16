class ExerciseLoad {
  final String exerciseName; // Pode ser o ID do exercício, dependendo de como está no seu app
  final double weight;
  final DateTime date;

  ExerciseLoad({
    required this.exerciseName,
    required this.weight,
    required this.date,
  });

  // Métodos úteis caso você esteja salvando em SQLite, Firebase ou SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'weight': weight,
      'date': date.toIso8601String(),
    };
  }

  factory ExerciseLoad.fromMap(Map<String, dynamic> map) {
    return ExerciseLoad(
      exerciseName: map['exerciseName'],
      weight: map['weight'],
      date: DateTime.parse(map['date']),
    );
  }
}