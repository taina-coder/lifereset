import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/task.dart';
import '../data/habit_catalog.dart';

// Importações necessárias para acessar o gênero salvo no onboarding
import '../services/storage_service.dart';
import '../models/player.dart';

class HabitService {
  static const String _historyKeyPrefix = 'habit_history_';
  static const String _lastResetKey = 'last_reset_date'; // Chave para controlar o reset

  // NOVO: Verifica se o dia mudou e reseta as tarefas
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

  // Escala de Treino Dinâmica baseada no Gênero
  static Future<void> checkWorkoutTask(List<Habit> activeHabits) async {
    // Carrega os dados do jogador salvos no onboarding
    final Player? player = await StorageService.loadPlayer();
    final String gender = player?.gender ?? 'Feminino'; // Fallback padrão caso não encontre

    Map<int, List<String>> workoutFeminino = {
      1: ["Cardio leve 15–20min", "Agachamento livre – 4x10", "Leg press – 4x12", "Afundo – 3x10 cada perna", "Cadeira extensora – 3x15", "Elevação pélvica – 4x12", "Abdutor – 3x15"],
      2: ["Cardio leve 20min", "Puxada na frente – 4x10", "Remada – 4x10", "Face pull – 3x15", "Rosca bíceps – 3x12", "Tríceps pulley – 3x12", "Abdominal – 3x15"],
      3: ["Cardio escada 20min", "Stiff – 4x10", "Mesa flexora – 4x12", "Hip thrust pesado – 4x8-10", "Coice no cabo – 3x15", "Passada longa – 3x12"],
      4: ["Caminhada leve 30–40min", "Alongamento completo", "Mobilidade", "Core leve (prancha 3x30s, abdominal curto 3x15)"],
      5: ["Cardio leve 20min", "Supino – 4x10", "Desenvolvimento ombro – 3x12", "Elevação lateral – 3x15", "Crucifixo máquina – 3x12", "Tríceps – 3x12", "Abdominal – 3x15"],
      6: ["Cardio: HIIT leve/moderado", "Agachamento", "Flexão", "Remada", "Afundo", "Abdominal"],
      7: ["Cardio", "Alongamento completo", "Mobilidade", "Core leve (prancha, abdominal curto)", "Treino leve"],
    };

    Map<int, List<String>> workoutMasculino = {
      1: ["Supino reto (barra ou máquina) – 3x10-12", "Supino inclinado – 3x10-12", "Crucifixo (máquina ou halter) – 3x12", "Tríceps corda – 3x12", "Tríceps testa – 3x10", "Cardio: esteira 30min (ritmo moderado)"],
      2: ["Puxada na frente – 3x10-12", "Remada baixa – 3x10-12", "Remada unilateral – 3x10", "Rosca direta – 3x10", "Rosca alternada – 3x12", "Cardio: esteira 30min"],
      3: ["Agachamento (livre ou máquina) – 3x10", "Leg press – 3x12", "Cadeira extensora – 3x12", "Cadeira flexora – 3x12", "Panturrilha – 3x15", "Cardio: esteira 30min leve"],
      4: ["Desenvolvimento – 3x10", "Elevação lateral – 3x12", "Elevação frontal – 3x12", "Abdominal reto – 3x15", "Prancha – 3x30-40s", "Cardio: esteira 30min"],
      5: ["Circuito leve full body", "Agachamento", "Flexão", "Remada", "Afundo", "Abdominal", "Cardio: esteira 30min (mais intenso)"],
      6: ["Cardio: HIIT leve/moderado", "Agachamento", "Flexão", "Remada", "Afundo", "Abdominal"],
      7: ["Cardio", "Alongamento completo", "Mobilidade", "Core leve (prancha, abdominal curto)", "Treino leve"],
    };

    // Define qual mapa de treino usar
    Map<int, List<String>> activeWorkout = (gender.toLowerCase() == 'masculino') 
        ? workoutMasculino 
        : workoutFeminino;

    List<String> todayTasks = activeWorkout[DateTime.now().weekday] ?? [];
    
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
}