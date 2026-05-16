import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../data/habit_catalog.dart';
import '../models/exercise_load.dart'; // NOVO: Importação do modelo de carga

class HabitService {
  static const String _historyKeyPrefix = 'habit_history_';
  static const String _lastResetKey = 'last_reset_date'; // Chave para controlar o reset
  static const String _loadHistoryKey = 'exercise_load_history'; // NOVO: Chave para as cargas

  // Verifica se o dia mudou e reseta as tarefas
  static Future<void> checkDailyReset(List<Habit> activeHabits) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toString().split(' ')[0];
    final String lastReset = prefs.getString(_lastResetKey) ?? "";

    // Se a data de hoje for diferente da data do último reset (ex: virou meia-noite)
    if (today != lastReset) {
      for (var habit in activeHabits) {
        for (var task in habit.tasks) {
          task.isCompleted = false; // Desmarca todas as tarefas
        }
      }
      // Atualiza a data do último reset para hoje
      await prefs.setString(_lastResetKey, today);
    }
  }

  // Cronograma AWS: Injeta APENAS o tópico do dia atual
  static Future<void> checkAWSTasks(List<Habit> activeHabits) async {
    List<String> awsTopics = [
      "Conceitos de Cloud Computing",
      "Modelo de Responsabilidade Compartilhada",
      "Regiões, AZs e Edge Locations",
      "IAM — usuários, roles e policies",
      "AWS CLI e SDKs",
      "AWS Lambda — fundamentos",
      "Lambda Layers, versões e aliases",
      "Configuração de memória, timeout e concurrency",
      "Amazon EC2 para aplicações",
      "AWS Elastic Beanstalk",
      "Amazon API Gateway — conceitos",
      "Autorização de APIs",
      "Integração API Gateway + Lambda",
      "AWS Step Functions",
      "Amazon S3 — armazenamento e eventos",
      "S3 Presigned URLs",
      "Versionamento e criptografia no S3",
      "Amazon EFS vs EBS",
      "Amazon DynamoDB — modelagem",
      "DynamoDB Indexes (LSI e GSI)",
      "DynamoDB Streams",
      "Amazon RDS",
      "Amazon SQS",
      "Dead Letter Queue (DLQ)",
      "Amazon SNS",
      "EventBridge vs SNS vs SQS",
      "Secrets Manager vs Parameter Store",
      "Criptografia com KMS",
      "Princípio do Least Privilege",
      "CloudWatch, X-Ray e CI/CD (CodeDeploy / CodePipeline)"
    ];

    int dayIndex = (DateTime.now().day - 1) % 30; 
    String todayTopic = awsTopics[dayIndex];

    for (var habit in activeHabits) {
      if (habit.id == 'estudos_aws') {
        if (habit.tasks.isEmpty || !habit.tasks.any((t) => t.title == todayTopic) || habit.tasks.length > 1) {
          habit.tasks.clear(); 
          habit.tasks.add(Task(title: todayTopic, impactTag: 'INTELIGENCIA', xpValue: 10.0));
        }
      }
    }
  }

  // Escala de Treino: Nova divisão semanal
  static Future<void> checkWorkoutTask(List<Habit> activeHabits) async {
    Map<int, List<String>> workout = {
      1: ["Cardio (1h): caminhada inclinada ou escada", "Agachamento livre – 4x12", "Leg press – 4x12", "Afundo – 3x10 cada perna", "Cadeira extensora – 3x15", "Elevação pélvica – 4x12", "Abdutor – 3x15"],
      2: ["Stiff – 4x10", "Mesa flexora – 4x12", "Glúteo no cabo – 3x15", "Elevação pélvica pesada – 4x10", "Passada longa – 3x12"],
      3: ["Cardio: corrida leve ou elíptico", "Supino – 4x10", "Remada – 4x10", "Puxada na frente – 3x12", "Desenvolvimento ombro – 3x12", "Rosca bíceps – 3x12", "Tríceps pulley – 3x12"],
      4: ["Cardio: escada ou HIIT leve", "Agachamento sumô – 3x15", "Leg press leve – 3x15", "Cadeira extensora – 3x15", "Abdutor – 3x20", "Panturrilha – 4x15", "Circuito leve sem descanso longo"],
      5: ["Cardio: caminhada inclinada", "Hip thrust – 5x10", "Stiff – 4x10", "Glúteo máquina – 4x12", "Coice no cabo – 3x15", "Abdutor pesado – 4x12"],
      6: ["Cardio: HIIT leve/moderado", "Agachamento", "Flexão", "Remada", "Afundo", "Abdominal"],
      7: ["Cardio", "Alongamento completo", "Mobilidade", "Core leve (prancha, abdominal curto)", "Treino leve"],
    };

    List<String> todayTasks = workout[DateTime.now().weekday] ?? [];
    
    for (var habit in activeHabits) {
      if (habit.id == 'treino_hibrido') {
        if (habit.tasks.isEmpty || !habit.tasks.any((t) => todayTasks.contains(t.title))) {
          habit.tasks.clear(); 
          for (var t in todayTasks) {
            habit.tasks.add(Task(title: t, impactTag: "FISICO", xpValue: 10.0));
          }
        }
      } else if (habit.tasks.isEmpty) {
        _injectDefaultTasks(habit);
      }
    }
  }

  static void _injectDefaultTasks(Habit habit) {
    final catalog = HabitCatalog.getAvailableHabits();
    try {
      final match = catalog.firstWhere((h) => h.id == habit.id);
      habit.tasks.addAll(match.tasks);
    } catch (_) {}
  }

  static Future<void> logHabitAction(String id, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    Map history = jsonDecode(prefs.getString('$_historyKeyPrefix$id') ?? '{}');
    history[DateTime.now().toString().split(' ')[0]] = progress;
    await prefs.setString('$_historyKeyPrefix$id', jsonEncode(history));
  }

  static Future<Map<DateTime, int>> getAggregatedProgress(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    Map<DateTime, int> aggregated = {};
    for (var key in prefs.getKeys().where((k) => k.startsWith(_historyKeyPrefix))) {
      if (id != null && key != '$_historyKeyPrefix$id') continue;
      Map history = jsonDecode(prefs.getString(key) ?? '{}');
      history.forEach((d, v) => aggregated[DateTime.parse(d)] = (v as num).toInt());
    }
    return aggregated;
  }

  static Future<double> getOverallProgress(Habit habit) async {
    final history = await getAggregatedProgress(habit.id);
    double totalScore = 0.0;
    String todayStr = DateTime.now().toString().split(' ')[0];

    history.forEach((date, score) {
      if (date.toString().split(' ')[0] != todayStr) {
        totalScore += score;
      }
    });

    double todayScore = 0.0;
    if (habit.tasks.isNotEmpty) {
      int completed = habit.tasks.where((t) => t.isCompleted).length;
      todayScore = (completed / habit.tasks.length) * 100;
    }
    totalScore += todayScore;

    int targetDays = 30;
    final match = RegExp(r'\d+').firstMatch(habit.duration);
    if (match != null) {
      targetDays = int.parse(match.group(0)!);
    }

    double finalProgress = totalScore / (targetDays * 100);
    return finalProgress.clamp(0.0, 1.0);
  }

  // =========================================================================
  // NOVAS FUNCIONALIDADES: ACOMPANHAMENTO DE CARGA
  // =========================================================================

  // Extrai uma lista consolidada dos exercícios a partir da sua escala de treino
  static List<String> getAvailableExercises() {
    return [
      "Agachamento livre", "Agachamento sumô", "Agachamento",
      "Leg press", "Leg press leve",
      "Cadeira extensora", "Mesa flexora",
      "Elevação pélvica", "Elevação pélvica pesada", "Hip thrust",
      "Abdutor", "Abdutor pesado", "Glúteo máquina", "Glúteo no cabo", "Coice no cabo",
      "Afundo", "Passada longa", "Stiff",
      "Supino", "Remada", "Puxada na frente", "Desenvolvimento ombro",
      "Rosca bíceps", "Tríceps pulley", "Panturrilha", "Flexão"
    ];
  }

  // Salva o peso de um exercício no SharedPreferences
  static Future<void> addExerciseLoad(String exerciseName, double weight) async {
    final prefs = await SharedPreferences.getInstance();
    
    final newLoad = ExerciseLoad(
      exerciseName: exerciseName,
      weight: weight,
      date: DateTime.now(),
    );

    // Busca o histórico atual
    String? historyJson = prefs.getString(_loadHistoryKey);
    List<dynamic> historyList = historyJson != null ? jsonDecode(historyJson) : [];

    // Adiciona o novo registro e salva
    historyList.add(newLoad.toMap());
    await prefs.setString(_loadHistoryKey, jsonEncode(historyList));
  }

  // Busca o histórico filtrado e ordenado para desenhar o gráfico
  static Future<List<ExerciseLoad>> getHistoryForExercise(String exerciseName) async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString(_loadHistoryKey);

    if (historyJson == null) return [];

    List<dynamic> historyList = jsonDecode(historyJson);
    
    // Converte de Map para Objeto, filtra pelo nome e ordena pela data (mais antigo -> mais recente)
    List<ExerciseLoad> loads = historyList
        .map((item) => ExerciseLoad.fromMap(item as Map<String, dynamic>))
        .where((e) => e.exerciseName == exerciseName)
        .toList();

    loads.sort((a, b) => a.date.compareTo(b.date));
    
    return loads;
  }
}