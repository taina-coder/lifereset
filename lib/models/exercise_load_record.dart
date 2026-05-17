class ExerciseLoadRecord {
  final String exerciseName;
  final DateTime date;
  final double loadKg;

  ExerciseLoadRecord({
    required this.exerciseName,
    required this.date,
    required this.loadKg,
  });

  String get dayKey =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'exerciseName': exerciseName,
        'date': dayKey,
        'loadKg': loadKg,
      };

  factory ExerciseLoadRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseLoadRecord(
      exerciseName: json['exerciseName'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      loadKg: (json['loadKg'] ?? 0.0).toDouble(),
    );
  }
}
