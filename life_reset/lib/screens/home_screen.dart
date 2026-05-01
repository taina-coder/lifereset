import 'package:flutter/material.dart';
import 'dart:ui'; 
import 'package:table_calendar/table_calendar.dart'; 
import '../models/habit.dart';
import '../data/habit_catalog.dart';
import '../services/storage_service.dart';
import '../services/habit_service.dart';
import '../services/level_service.dart';
import '../services/attribute_service.dart'; 
import '../services/checkin_service.dart'; 
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
    
    setState(() {
      task.isCompleted = isNowCompleted;
    });

    if (isNowCompleted) {
      totalXp = await LevelService.addXp(task.xpValue);
      await AttributeService.applyTaskReward(task, isAdding: true);
      await CheckinService.checkInToday(); 
    } else {
      totalXp = await LevelService.removeXp(task.xpValue);
      await AttributeService.applyTaskReward(task, isAdding: false);
    }

    await StorageService.saveActiveHabits(activeHabits);
    await HabitService.logHabitAction(habit.id, habit.dayProgress * 100);
    
    overallProgressMap[habit.id] = await HabitService.getOverallProgress(habit);
    checkinHistory = await CheckinService.getCheckinHistory(); 
    
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
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildMiniCalendar(),
                      ),
                      Expanded(child: _buildEmptyState()),
                    ],
                  )
                : ListView.builder(
                    key: const PageStorageKey('main_habit_scroll'),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: activeHabits.length + 1, 
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildMiniCalendar(),
                        );
                      }
                      return _buildHabitCard(activeHabits[index - 1], index - 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // CALENDÁRIO ULTRACÓMPACTO: Sem dias da semana e ainda menor
  Widget _buildMiniCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
        
        // ESCONDE OS DIAS DA SEMANA E DIMINUI A ALTURA
        daysOfWeekVisible: false, 
        rowHeight: 28, 
        
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white24, size: 20),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          headerMargin: EdgeInsets.only(bottom: 4), // Aproxima os quadrados do título
        ),
        
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(2), // Quase colados
          
          defaultTextStyle: const TextStyle(color: Colors.white38, fontSize: 9),
          weekendTextStyle: const TextStyle(color: Colors.white38, fontSize: 9),
          
          // Estilo minimalista para dias vazios
          defaultDecoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04), 
            borderRadius: BorderRadius.circular(4), // Mais quadrado
          ),
          weekendDecoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(4),
          ),

          todayTextStyle: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: colorPrimary.withOpacity(0.4), width: 1),
          ),

          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
          selectedDecoration: BoxDecoration(
            color: colorPrimary, 
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        
        selectedDayPredicate: (day) {
          String formattedDay = day.toIso8601String().split('T')[0];
          return checkinHistory.contains(formattedDay);
        },
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