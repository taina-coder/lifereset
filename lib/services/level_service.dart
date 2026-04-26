import 'package:shared_preferences/shared_preferences.dart';

class LevelService {
  static const String _xpKey = 'user_xp_total';
  static const int xpPerTask = 10; // Cada check dá 10 de XP
  static const int xpPerLevel = 550; // Quantidade para subir de nível
  static const int maxLevel = 100;

  /// Adiciona XP quando uma task é marcada
  static Future<int> addXp() async {
    final prefs = await SharedPreferences.getInstance();
    int currentXp = prefs.getInt(_xpKey) ?? 0;
    currentXp += xpPerTask;
    await prefs.setInt(_xpKey, currentXp);
    return currentXp;
  }

  /// Remove XP se desmarcar a task
  static Future<int> removeXp() async {
    final prefs = await SharedPreferences.getInstance();
    int currentXp = prefs.getInt(_xpKey) ?? 0;
    if (currentXp >= xpPerTask) currentXp -= xpPerTask;
    await prefs.setInt(_xpKey, currentXp);
    return currentXp;
  }

  static Future<int> getTotalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
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