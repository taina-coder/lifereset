import 'package:flutter/material.dart';
import 'dart:ui'; 
import '../models/habit.dart';
import '../data/habit_catalog.dart';
import '../services/storage_service.dart';
import '../services/habit_service.dart';
import '../services/level_service.dart';
import '../services/attribute_service.dart'; 
import '../widgets/custom_drawer.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // PALETA CYBER-TECH PADRONIZADA
  final Color colorBackground = const Color(0xFF0A0A0A);
  final Color colorAccent = const Color(0xFFD0FF00); 
  final Color colorPrimary = const Color(0xFF8116E0); 
  final Color colorSurface = const Color(0xFF121212);
  final Color colorText = const Color(0xFFFEFFFC);

  List<Habit> activeHabits = [];
  Map<String, double> overallProgressMap = {}; // Controla o progresso de longo prazo (30 dias)
  bool isLoading = true;
  int totalXp = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Lógica de carregamento com verificação de reset diário e injeção de tasks
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    // 1. Carrega os hábitos ativos do disco
    List<Habit> habits = await StorageService.loadActiveHabits();
    
    // 2. COLD START CHECK: Se a lista estiver vazia, popula com o catálogo
    if (habits.isEmpty) {
      final catalog = HabitCatalog.getAvailableHabits();
      await StorageService.updateHabitsFromCatalog(catalog);
      habits = await StorageService.loadActiveHabits();
    }
    
    // 3. Verifica se o dia mudou para resetar as tarefas visuais (00:00)
    await HabitService.checkDailyReset(habits);

    // 4. Executa a injeção do tópico de HOJE (AWS e Treino)
    await HabitService.checkAWSTasks(habits); 
    await HabitService.checkWorkoutTask(habits);

    // 5. Salva o estado atualizado para garantir persistência
    await StorageService.saveActiveHabits(habits);

    // 6. Carrega o XP total e calcula o progresso acumulado (30 dias)
    final xp = await LevelService.getTotalXp();
    Map<String, double> progressMap = {};
    for (var h in habits) {
      progressMap[h.id] = await HabitService.getOverallProgress(h);
    }

    setState(() {
      activeHabits = habits; 
      overallProgressMap = progressMap;
      totalXp = xp;
      isLoading = false;
    });
  }

  void _toggleSubTask(int habitIndex, int taskIndex) async {
    final habit = activeHabits[habitIndex];
    final task = habit.tasks[taskIndex];
    bool isNowCompleted = !task.isCompleted;
    
    setState(() {
      task.isCompleted = isNowCompleted;
    });

    // Lógica de RPG bidirecional (XP e Atributos)
    if (isNowCompleted) {
      // CORREÇÃO AQUI: Passando o task.xpValue para o motor de Level
      totalXp = await LevelService.addXp(task.xpValue);
      await AttributeService.applyTaskReward(task, isAdding: true);
    } else {
      // CORREÇÃO AQUI: Passando o task.xpValue para o motor de Level
      totalXp = await LevelService.removeXp(task.xpValue);
      await AttributeService.applyTaskReward(task, isAdding: false);
    }

    // Persiste a mudança e loga o progresso do dia no histórico
    await StorageService.saveActiveHabits(activeHabits);
    await HabitService.logHabitAction(habit.id, habit.dayProgress * 100);
    
    // Atualiza a barra de 30 dias em tempo real
    overallProgressMap[habit.id] = await HabitService.getOverallProgress(habit);
    
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: colorBackground,
        body: Center(child: CircularProgressIndicator(color: colorAccent)),
      );
    }

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("LIFE RESET", 
          style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_sync, color: colorAccent),
            onPressed: () async {
              final catalog = HabitCatalog.getAvailableHabits();
              await StorageService.updateHabitsFromCatalog(catalog);
              _loadData();
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          _buildLevelHeader(),
          Expanded(
            child: activeHabits.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    key: const PageStorageKey('main_habit_scroll'),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: activeHabits.length,
                    itemBuilder: (context, index) => _buildHabitCard(activeHabits[index], index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelHeader() {
    int level = LevelService.getLevel(totalXp);
    double progress = LevelService.getLevelProgress(totalXp);
    int nextLevelXp = LevelService.xpPerLevel - (totalXp % LevelService.xpPerLevel);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: colorSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorAccent.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            // Preenchimento interno para evitar corte de glifos inclinados
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("NÍVEL $level", 
                          style: TextStyle(color: colorAccent, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        Text("$totalXp TOTAL XP", 
                          style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.bolt, color: colorAccent, size: 32),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: colorAccent,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text("FALTAM $nextLevelXp XP PARA LEVEL UP", 
                    style: TextStyle(color: Colors.grey[700], fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, int habitIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Image.asset(
              habit.imageUrl ?? '', 
              height: 140, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(height: 140, color: Colors.white10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title.toUpperCase(), 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 12),
                
                // Barra baseada no progresso acumulado de 30 dias
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: overallProgressMap[habit.id] ?? 0.0,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: colorPrimary,
                    minHeight: 3,
                  ),
                ),
                
                const SizedBox(height: 24),

                ...habit.tasks.asMap().entries.map((entry) {
                  int taskIdx = entry.key;
                  Task task = entry.value;
                  return _buildSubTaskItem(
                    task.title, 
                    task.isCompleted, 
                    () => _toggleSubTask(habitIndex, taskIdx)
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTaskItem(String title, bool isDone, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDone ? colorAccent.withOpacity(0.05) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDone ? colorAccent.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(isDone ? Icons.check_circle : Icons.radio_button_off, 
              color: isDone ? colorAccent : Colors.grey[800], size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(
                color: isDone ? colorAccent : colorText, 
                fontSize: 13,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                decoration: isDone ? TextDecoration.lineThrough : null,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear, size: 60, color: colorPrimary.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("MODO STANDBY ATIVO", 
            style: TextStyle(color: colorPrimary.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 3)),
        ],
      ),
    );
  }
}