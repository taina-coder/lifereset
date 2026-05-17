import 'package:flutter/material.dart';
import 'dart:ui'; 
import '../models/habit.dart';
import '../data/habit_catalog.dart';
import '../services/storage_service.dart';
import '../services/habit_service.dart';
import '../services/level_service.dart';
import '../services/attribute_service.dart'; 
import '../services/exercise_load_service.dart';
import '../widgets/custom_drawer.dart';
import '../models/task.dart';
import '../services/checkin_service.dart';

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
  Map<String, double> overallProgressMap = {}; 
  List<String> checkinHistory = []; 
  bool isLoading = true;
  int totalXp = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    List<Habit> habits = await StorageService.loadActiveHabits();
    
    if (habits.isEmpty) {
      final catalog = HabitCatalog.getAvailableHabits();
      await StorageService.updateHabitsFromCatalog(catalog);
      habits = await StorageService.loadActiveHabits();
    }
    
    await HabitService.checkDailyReset(habits);
    await HabitService.checkAWSTasks(habits); 
    await HabitService.checkWorkoutTask(habits);
    await StorageService.saveActiveHabits(habits);

    final xp = await LevelService.getTotalXp();
    final history = await CheckinService.getCheckinHistory();

    Map<String, double> progressMap = {};
    for (var h in habits) {
      progressMap[h.id] = await HabitService.getOverallProgress(h);
    }

    setState(() {
      activeHabits = habits; 
      overallProgressMap = progressMap;
      totalXp = xp;
      checkinHistory = history;
      isLoading = false;
    });
  }

  void _toggleSubTask(int habitIndex, int taskIndex) async {
    final habit = activeHabits[habitIndex];
    final task = habit.tasks[taskIndex];
    bool isNowCompleted = !task.isCompleted;

    double? loadKg;
    if (isNowCompleted && habit.id == 'treino_hibrido') {
      loadKg = await _askExerciseLoad(task.title);
      if (loadKg == null) return;
      if (!mounted) return;
    }
    
    setState(() {
      task.isCompleted = isNowCompleted;
    });

    if (isNowCompleted) {
      if (habit.id == 'treino_hibrido' && loadKg != null) {
        await ExerciseLoadService.saveLoad(
          exerciseName: task.title,
          loadKg: loadKg,
        );
      }
      totalXp = await LevelService.addXp(task.xpValue);
      await AttributeService.applyTaskReward(task, isAdding: true);
      await CheckinService.checkInToday(); 
    } else {
      if (habit.id == 'treino_hibrido') {
        await ExerciseLoadService.removeTodayLoad(task.title);
      }
      totalXp = await LevelService.removeXp(task.xpValue);
      await AttributeService.applyTaskReward(task, isAdding: false);
    }

    await StorageService.saveActiveHabits(activeHabits);
    await HabitService.logHabitAction(habit.id, habit.dayProgress * 100);
    overallProgressMap[habit.id] = await HabitService.getOverallProgress(habit);
    checkinHistory = await CheckinService.getCheckinHistory();

    if (!mounted) return;
    setState(() {}); 
  }

  Future<double?> _askExerciseLoad(String exerciseName) async {
    final controller = TextEditingController();
    String? errorText;

    final result = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: colorAccent.withOpacity(0.25)),
              ),
              title: Text(
                "REGISTRAR CARGA",
                style: TextStyle(
                  color: colorAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      color: colorText,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: InputDecoration(
                      suffixText: "KG",
                      suffixStyle: TextStyle(color: colorAccent, fontWeight: FontWeight.bold),
                      hintText: "0",
                      hintStyle: const TextStyle(color: Colors.white12),
                      errorText: errorText,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colorAccent.withOpacity(0.7)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("CANCELAR"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final normalized = controller.text.trim().replaceAll(',', '.');
                    final value = double.tryParse(normalized);
                    if (value == null || value < 0) {
                      setDialogState(() {
                        errorText = "Digite uma carga valida";
                      });
                      return;
                    }
                    Navigator.pop(dialogContext, value);
                  },
                  child: const Text(
                    "SALVAR",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
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
          // NÍVEL GLOBAL (Fixo no topo da tela)
          _buildLevelHeader(),
          
          // ÁREA ROLÁVEL (Calendário + Cards)
          Expanded(
            child: ListView(
              key: const PageStorageKey('main_habit_scroll'),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                
                // O calendário agora rola junto com os cards
                _buildMonthlyCheckinBlocks(),

                if (activeHabits.isEmpty) 
                  _buildEmptyState()
                else 
                  ...activeHabits.asMap().entries.map((entry) => _buildHabitCard(entry.value, entry.key)),
              ],
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
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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

  Widget _buildMonthlyCheckinBlocks() {
    DateTime now = DateTime.now();
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    String currentMonthStr = now.month.toString().padLeft(2, '0');
    String currentYearStr = now.year.toString();

    return Container(
      // A margem lateral foi removida para alinhar com os cards dentro do ListView
      margin: const EdgeInsets.only(bottom: 24), 
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("CHECK-IN MENSAL", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Icon(Icons.calendar_view_month, color: Colors.white24, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(daysInMonth, (index) {
              int day = index + 1;
              String dayStr = day.toString().padLeft(2, '0');
              String dateToCheck = "$currentYearStr-$currentMonthStr-$dayStr";
              
              bool isCheckedIn = checkinHistory.contains(dateToCheck);
              bool isFuture = day > now.day;
              bool isToday = day == now.day;

              Color blockColor;
              Color borderColor;

              if (isCheckedIn) {
                blockColor = colorAccent; 
                borderColor = colorAccent;
              } else if (isFuture) {
                blockColor = Colors.transparent; 
                borderColor = Colors.white.withOpacity(0.05);
              } else {
                blockColor = Colors.white.withOpacity(0.05); 
                borderColor = Colors.transparent;
              }

              if (isToday && !isCheckedIn) {
                borderColor = colorAccent.withOpacity(0.5);
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: isCheckedIn ? [
                    BoxShadow(color: colorAccent.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)
                  ] : [],
                ),
              );
            }),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear, size: 60, color: colorPrimary.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text("MODO STANDBY ATIVO", 
              style: TextStyle(color: colorPrimary.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 3)),
          ],
        ),
      ),
    );
  }
}
