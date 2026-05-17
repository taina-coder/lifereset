import 'dart:convert';
import '../models/exercise_load_record.dart';
import 'local_database_service.dart';

class ExerciseLoadService {
  static const String _historyKey = 'exercise_load_history';

  static Future<List<ExerciseLoadRecord>> loadHistory() async {
    final data = await LocalDatabaseService.getValue<String>(_historyKey);
    if (data == null || data.isEmpty) return [];

    final decoded = jsonDecode(data) as List<dynamic>;
    final records = decoded
        .map((item) => ExerciseLoadRecord.fromJson(Map<String, dynamic>.from(item)))
        .where((record) => record.exerciseName.isNotEmpty)
        .toList();

    records.sort((a, b) => a.date.compareTo(b.date));
    return records;
  }

  static Future<void> saveLoad({
    required String exerciseName,
    required double loadKg,
    DateTime? date,
  }) async {
    final records = await loadHistory();
    final recordDate = date ?? DateTime.now();
    final newRecord = ExerciseLoadRecord(
      exerciseName: exerciseName,
      date: recordDate,
      loadKg: loadKg,
    );

    final existingIndex = records.indexWhere(
      (record) =>
          record.exerciseName == exerciseName && record.dayKey == newRecord.dayKey,
    );

    if (existingIndex >= 0) {
      records[existingIndex] = newRecord;
    } else {
      records.add(newRecord);
    }

    records.sort((a, b) => a.date.compareTo(b.date));
    await LocalDatabaseService.setValue(
      _historyKey,
      jsonEncode(records.map((record) => record.toJson()).toList()),
    );
  }

  static Future<void> removeTodayLoad(String exerciseName) async {
    final records = await loadHistory();
    final today = ExerciseLoadRecord(
      exerciseName: exerciseName,
      date: DateTime.now(),
      loadKg: 0,
    ).dayKey;

    records.removeWhere(
      (record) => record.exerciseName == exerciseName && record.dayKey == today,
    );

    await LocalDatabaseService.setValue(
      _historyKey,
      jsonEncode(records.map((record) => record.toJson()).toList()),
    );
  }
}
