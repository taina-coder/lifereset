import '../models/attribute_stats.dart'; 
import 'storage_service.dart';
import '../models/task.dart';

class AttributeService {
  
  // Adicionamos o parâmetro 'isAdding' para saber se deve somar ou subtrair
  static Future<void> applyTaskReward(Task task, {bool isAdding = true}) async {
    // 1. Carrega os stats atuais do Storage
    AttributeStats currentStats = await StorageService.loadAttributeStats();
    
    // 2. Define o multiplicador (1 para somar, -1 para subtrair)
    double multiplier = isAdding ? 1.0 : -1.0;
    double points = (task.xpValue / 100) * multiplier; 
    double xpChange = task.xpValue * multiplier;

    // 3. Aplica ou remove o status conforme a tag da task
    switch (task.impactTag.toUpperCase()) {
      case 'FISICO':
        currentStats.physique += points;
        currentStats.stamina += (points * 0.5);
        break;
      case 'INTELIGENCIA':
        currentStats.intellect += points;
        // Bônus para AWS e SQL também é removido se desmarcar
        if (task.title.toUpperCase().contains('AWS') || task.title.toUpperCase().contains('SQL')) {
          currentStats.intellect += (0.02 * multiplier);
        }
        break;
      case 'SANIDADE':
        currentStats.sanity += points; 
        break;
      case 'SAUDE':
        currentStats.health += points;
        break;
      case 'ESTAMINA':
        currentStats.stamina += points;
        break;
    }

    // 4. Lógica de Level Geral (XP acumulado)
    currentStats.currentLevelXp += xpChange;
    
    // Sobe de nível a cada 100 XP
    if (currentStats.currentLevelXp >= 100.0) { 
      currentStats.totalLevel += 1;
      currentStats.currentLevelXp -= 100.0; // Mantém o resto do XP
    } 
    // Desce de nível se o XP ficar negativo (correção de erro)
    else if (currentStats.currentLevelXp < 0 && currentStats.totalLevel > 1) {
      currentStats.totalLevel -= 1;
      currentStats.currentLevelXp += 100.0;
    }

    // Garante que o nível mínimo seja 1 e o XP não fique negativo no level 1
    if (currentStats.totalLevel < 1) currentStats.totalLevel = 1;
    if (currentStats.totalLevel == 1 && currentStats.currentLevelXp < 0) {
      currentStats.currentLevelXp = 0;
    }

    // 5. Clamping e Sincronização
    _normalizeStats(currentStats);
    await StorageService.saveLevel(currentStats.totalLevel);
    await StorageService.saveAttributeStats(currentStats);
  }

  static void _normalizeStats(AttributeStats stats) {
    stats.physique = stats.physique.clamp(0.0, 1.0);
    stats.intellect = stats.intellect.clamp(0.0, 1.0);
    stats.sanity = stats.sanity.clamp(0.0, 1.0);
    stats.health = stats.health.clamp(0.0, 1.0);
    stats.stamina = stats.stamina.clamp(0.0, 1.0);
  }
}