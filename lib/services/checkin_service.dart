import 'local_database_service.dart';

class CheckinService {
  static const String _datesKey = 'checkin_dates_history';

  // Salva a data de hoje no histórico
  static Future<void> checkInToday() async {
    List<String> dates = await getCheckinHistory();
    
    // Pega apenas a data (YYYY-MM-DD), ignorando a hora
    String today = DateTime.now().toIso8601String().split('T')[0];

    if (!dates.contains(today)) {
      dates.add(today);
      await LocalDatabaseService.setStringList(_datesKey, dates);
    }
  }

  // Carrega todas as datas que você fez check-in
  static Future<List<String>> getCheckinHistory() async {
    return LocalDatabaseService.getStringList(_datesKey);
  }

  // Calcula os dias consecutivos (A Ofensiva/Streak)
  static Future<int> getCurrentStreak() async {
    List<String> dates = await getCheckinHistory();
    if (dates.isEmpty) return 0;

    // Ordena da data mais recente para a mais antiga
    dates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    String todayStr = currentDate.toIso8601String().split('T')[0];

    // Regra de quebra: Se não fez check-in hoje e nem ontem, perdeu a ofensiva
    if (!dates.contains(todayStr)) {
      DateTime yesterday = currentDate.subtract(const Duration(days: 1));
      String yesterdayStr = yesterday.toIso8601String().split('T')[0];
      if (!dates.contains(yesterdayStr)) {
        return 0; // Zerou o streak
      } else {
        currentDate = yesterday; // A ofensiva está viva através de ontem
      }
    }

    // Conta quantos dias seguidos existem na lista
    for (String dateStr in dates) {
      String expectedStr = currentDate.toIso8601String().split('T')[0];
      if (dateStr == expectedStr) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break; // A corrente quebrou
      }
    }
    return streak;
  }
}
