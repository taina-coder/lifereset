class Player {
  String name;
  int age;
  String gender;
  int level;
  double xp; // Alterado para double para suportar progressão fracionada

  Player({
    required this.name,
    required this.age,
    required this.gender,
    required this.level,
    required this.xp,
  });

  // Converte o Player para JSON para o StorageService
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'level': level,
      'xp': xp,
    };
  }

  // Cria um Player a partir do JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] ?? 'Recruta',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'N/A',
      level: json['level'] ?? 1,
      xp: (json['xp'] is int) ? (json['xp'] as int).toDouble() : (json['xp'] ?? 0.0),
    );
  }

  // Lógica de soma corrigida para ser acumulativa e gradual
  bool addXP(double amount) {
    xp += amount;
    bool leveledUp = false;

    // Enquanto o XP for maior que 100, sobe de nível e mantém o resto
    while (xp >= 100.0) {
      xp -= 100.0;
      level++;
      leveledUp = true;
    }
    
    return leveledUp;
  }

  void removeXP(double amount) {
    xp -= amount;
    if (xp < 0 && level > 1) {
      level--;
      xp += 100.0;
    }
    if (xp < 0) xp = 0.0;
  }
}