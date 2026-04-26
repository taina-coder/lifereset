class Task {
  final String title;
  bool isCompleted;
  String impactTag; // Ex: 'INTELIGENCIA', 'FISICO'
  double xpValue;   // Quanto de XP essa tarefa dá

  Task({
    required this.title,
    this.isCompleted = false,
    this.impactTag = 'SANIDADE',
    this.xpValue = 10.0,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'isCompleted': isCompleted,
    'impactTag': impactTag,
    'xpValue': xpValue,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title: json['title'] ?? '',
    isCompleted: json['isCompleted'] ?? false,
    impactTag: json['impactTag'] ?? 'SANIDADE',
    xpValue: (json['xpValue'] ?? 10.0).toDouble(),
  );
}