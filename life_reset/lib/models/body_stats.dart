class BodyStats {
  double weight;
  double waist;
  double thighs;
  double chest;
  DateTime date;

  BodyStats({
    required this.weight,
    required this.waist,
    required this.thighs,
    required this.chest,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'waist': waist,
    'thighs': thighs,
    'chest': chest,
    'date': date.toIso8601String(),
  };

  factory BodyStats.fromJson(Map<String, dynamic> json) => BodyStats(
    weight: json['weight'],
    waist: json['waist'],
    thighs: json['thighs'],
    chest: json['chest'],
    date: DateTime.parse(json['date']),
  );
}