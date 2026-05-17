// ignore_for_file: unused_import

import 'dart:convert';
import '../models/habit.dart';
import '../models/task.dart';
import '../models/attribute_stats.dart';
import '../models/player.dart';
import 'habit_service.dart';
import 'local_database_service.dart';

class StorageService {
  static const String _playerKey = 'player_data';
  static const String _statsKey = 'user_attributes';
  static const String _activeHabitsKey = 'active_habits';

  // ==========================================
  // 1. IDENTIDADE E NÍVEL (PLAYER)
  // ==========================================

  static Future<bool> hasPlayer() async {
    final data = await LocalDatabaseService.getValue<String>(_playerKey);
    return data != null && data.isNotEmpty;
  }

  static Future<void> savePlayer(Player player) async {
    await LocalDatabaseService.setValue(_playerKey, jsonEncode(player.toJson()));
  }

  static Future<Player> loadPlayer() async {
    final data = await LocalDatabaseService.getValue<String>(_playerKey);
    if (data != null) {
      return Player.fromJson(jsonDecode(data));
    }
    return Player(name: "Recruta", age: 0, gender: "N/A", level: 1, xp: 0);
  }

  // MÉTODOS DE NÍVEL (CURA O ERRO NA LEVEL_SCREEN)
  static Future<int> loadLevel() async {
    final player = await loadPlayer();
    return player.level;
  }

  static Future<void> saveLevel(int level) async {
    final player = await loadPlayer();
    player.level = level;
    await savePlayer(player);
  }

  static Future<void> saveUserName(String name) async {
    final player = await loadPlayer();
    player.name = name;
    await savePlayer(player);
  }

  static Future<String> loadUserName() async {
    final player = await loadPlayer();
    return player.name.isNotEmpty ? player.name : "Tainá Oliveira";
  }

  // ==========================================
  // 2. MEDIDAS CORPORAIS (RESTAURADOS)
  // ==========================================

  static Future<void> saveBodyStats(Map<String, double> stats) async {
    await LocalDatabaseService.setValue('user_body_stats', jsonEncode(stats));
  }

  static Future<Map<String, double>?> loadBodyStats() async {
    String? data = await LocalDatabaseService.getValue<String>('user_body_stats');
    if (data == null) return null;
    final Map<String, dynamic> decoded = jsonDecode(data);
    return decoded.map((key, value) => MapEntry(key, value.toDouble()));
  }

  // ==========================================
  // 3. HÁBITOS E TASKS DINÂMICAS
  // ==========================================

  static Future<List<Habit>> loadActiveHabits() async {
    List<String> habitsJson = await LocalDatabaseService.getStringList(_activeHabitsKey);
    if (habitsJson.isEmpty) return [];
    return habitsJson.map((jsonStr) => Habit.fromJson(jsonDecode(jsonStr))).toList();
  }

  static Future<void> saveActiveHabits(List<Habit> habits) async {
    
    // Injeta a lógica do HabitService (Cronograma AWS e Treino do Dia)
    await HabitService.checkAWSTasks(habits);
    await HabitService.checkWorkoutTask(habits);

    List<String> habitsJson = habits.map((h) => jsonEncode(h.toJson())).toList();
    await LocalDatabaseService.setStringList(_activeHabitsKey, habitsJson);
  }

  static Future<void> updateHabitsFromCatalog(List<Habit> catalogHabits) async {
    List<Habit> currentActive = await loadActiveHabits();
    List<Habit> updatedList = [];

    for (var active in currentActive) {
      try {
        final catalogMatch = catalogHabits.firstWhere((h) => h.id == active.id);
        updatedList.add(Habit(
          id: active.id,
          title: catalogMatch.title,
          category: catalogMatch.category,
          duration: catalogMatch.duration,
          imageUrl: catalogMatch.imageUrl,
          goalDescription: catalogMatch.goalDescription,
          scientificStudy: catalogMatch.scientificStudy,
          fitPercentage: catalogMatch.fitPercentage,
          benefits: catalogMatch.benefits,
          tasks: active.tasks.isNotEmpty ? active.tasks : catalogMatch.tasks,
        ));
      } catch (e) {
        updatedList.add(active);
      }
    }
    await saveActiveHabits(updatedList);
  }

  // ==========================================
  // 4. ATRIBUTOS RPG E IMAGEM
  // ==========================================

  static Future<void> saveAttributeStats(AttributeStats stats) async {
    await LocalDatabaseService.setValue(_statsKey, jsonEncode(stats.toJson()));
  }

  static Future<AttributeStats> loadAttributeStats() async {
    final data = await LocalDatabaseService.getValue<String>(_statsKey);
    return data != null ? AttributeStats.fromJson(jsonDecode(data)) : AttributeStats();
  }

  static Future<String> saveProfileImage(String path) async {
    final savedFile = await LocalDatabaseService.copyFileToDatabaseDirectory(
      path,
      'profile_image.jpg',
    );
    await LocalDatabaseService.setValue('profile_image_path', savedFile.path);
    return savedFile.path;
  }

  static Future<String?> loadProfileImage() async {
    return LocalDatabaseService.getValue<String>('profile_image_path');
  }

  static Future<void> clearAllData() async {
    await LocalDatabaseService.clearDatabase();
    await LocalDatabaseService.clearCache();
  }
}
