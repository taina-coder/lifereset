import 'local_database_service.dart';

class LevelService {
  static const String _xpKey = 'user_xp_total';
  static const int xpPerLevel = 550; // Quantidade para subir de nível global
  static const int maxLevel = 100;

  /// Adiciona XP quando uma task é marcada, recebendo o valor dinâmico
  static Future<int> addXp(double amount) async {
    int currentXp = await getTotalXp();
    currentXp += amount.toInt();
    await LocalDatabaseService.setValue(_xpKey, currentXp);
    return currentXp;
  }

  /// Remove XP se desmarcar a task
  static Future<int> removeXp(double amount) async {
    int currentXp = await getTotalXp();
    if (currentXp >= amount) currentXp -= amount.toInt();
    await LocalDatabaseService.setValue(_xpKey, currentXp);
    return currentXp;
  }

  static Future<int> getTotalXp() async {
    return await LocalDatabaseService.getValue<int>(_xpKey) ?? 0;
  }

  /// Retorna o nível atual (Total XP / XP por Nível)
  static int getLevel(int totalXp) {
    int lvl = (totalXp / xpPerLevel).floor() + 1;
    return lvl > maxLevel ? maxLevel : lvl;
  }

  /// Retorna quanto de XP falta para o próximo nível (para a barrinha)
  static double getLevelProgress(int totalXp) {
    int currentLevelXp = totalXp % xpPerLevel;
    return currentLevelXp / xpPerLevel;
  }
}
