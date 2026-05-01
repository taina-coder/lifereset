class AttributeStats {
  // ATRIBUTOS ORIGINAIS (MANTIDOS PARA NÃO PERDER DADOS)
  double physique;
  double stamina;
  double intellect;
  double sanity;
  double health;
  
  // NOVOS ATRIBUTOS ADICIONADOS
  double appearance;
  double selfEsteem;
  double career;
  double social;

  int totalLevel;
  double currentLevelXp;

  AttributeStats({
    this.physique = 0.0,    
    this.stamina = 0.0,     
    this.intellect = 0.0,   
    this.sanity = 0.0,      
    this.health = 0.0,      
    this.appearance = 0.0,  // NOVO
    this.selfEsteem = 0.0,  // NOVO
    this.career = 0.0,      // NOVO
    this.social = 0.0,      // NOVO
    this.totalLevel = 1,    
    this.currentLevelXp = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'physique': physique,
    'stamina': stamina,
    'intellect': intellect,
    'sanity': sanity,
    'health': health,
    'appearance': appearance,
    'selfEsteem': selfEsteem,
    'career': career,
    'social': social,
    'totalLevel': totalLevel,
    'currentLevelXp': currentLevelXp,
  };

  factory AttributeStats.fromJson(Map<String, dynamic> json) => AttributeStats(
    physique: (json['physique'] ?? 0.0).toDouble(),
    stamina: (json['stamina'] ?? 0.0).toDouble(),
    intellect: (json['intellect'] ?? 0.0).toDouble(),
    sanity: (json['sanity'] ?? 0.0).toDouble(),
    health: (json['health'] ?? 0.0).toDouble(),
    appearance: (json['appearance'] ?? 0.0).toDouble(),
    selfEsteem: (json['selfEsteem'] ?? 0.0).toDouble(),
    career: (json['career'] ?? 0.0).toDouble(),
    social: (json['social'] ?? 0.0).toDouble(),
    totalLevel: json['totalLevel'] ?? 1,
    currentLevelXp: (json['currentLevelXp'] ?? 0.0).toDouble(),
  );
}