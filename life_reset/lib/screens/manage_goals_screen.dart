import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/habit_service.dart';

class ManageGoalsScreen extends StatefulWidget {
  const ManageGoalsScreen({super.key});

  @override
  State<ManageGoalsScreen> createState() => _ManageGoalsScreenState();
}

class _ManageGoalsScreenState extends State<ManageGoalsScreen> {
  // PALETA CYBER-TECH PADRONIZADA
  final Color colorBackground = const Color(0xFF0A0A0A);
  final Color colorAccent = const Color(0xFFD0FF00);  // Verde Ácido
  final Color colorPrimary = const Color(0xFF8116E0); // Roxo
  final Color colorSurface = const Color(0xFF121212);
  final Color colorDanger = const Color(0xFFFF0055);  // Magenta Neon

  List<Habit> activeHabits = [];
  Map<DateTime, int> generalHistory = {};
  Map<String, Map<DateTime, int>> individualHistories = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    final habits = await StorageService.loadActiveHabits();
    final history = await HabitService.getAggregatedProgress(null);

    Map<String, Map<DateTime, int>> histories = {};
    for (var habit in habits) {
      histories[habit.id] = await HabitService.getAggregatedProgress(habit.id);
    }

    setState(() {
      activeHabits = habits;
      generalHistory = history;
      individualHistories = histories;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text("GESTÃO DE PROTOCOLOS", 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("PERFORMANCE GLOBAL"),
                  const SizedBox(height: 20),
                  _buildChartContainer(generalHistory, colorAccent, true),
                  
                  const SizedBox(height: 40),
                  _buildSectionTitle("DESEMPENHO POR SETOR"),
                  const SizedBox(height: 20),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: activeHabits.length,
                    itemBuilder: (context, index) {
                      final habit = activeHabits[index];
                      // ANIMAÇÃO DE ENTRADA NO GRID
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Transform.scale(scale: value, child: child),
                        child: _buildMiniChartCard(habit),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  _buildSectionTitle("METAS ATIVAS (DESLIZE PARA REMOVER)"),
                  const SizedBox(height: 20),
                  ...activeHabits.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Habit habit = entry.value;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600 + (idx * 100)),
                      curve: Curves.easeOutQuint,
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(habit.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: colorDanger,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_sweep, color: Colors.white),
                          ),
                          onDismissed: (_) => _confirmDeletion(habit),
                          child: _buildHabitManageCard(habit),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: colorAccent, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2),
    );
  }

  Widget _buildChartContainer(Map<DateTime, int> history, Color color, bool showFill) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _generateSpots(history),
              isCurved: true,
              color: color,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: showFill,
                color: color.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(Map<DateTime, int> history) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - i));
      DateTime normalized = DateTime(date.year, date.month, date.day);
      double val = (history[normalized] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), val));
    }
    return spots;
  }

  Widget _buildMiniChartCard(Habit habit) {
    final history = individualHistories[habit.id] ?? {};
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(habit.title.toUpperCase(), 
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const Spacer(),
          SizedBox(
            height: 50,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(history),
                    isCurved: true,
                    color: colorPrimary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitManageCard(Habit habit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.terminal, color: colorPrimary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colorDanger, size: 20),
            onPressed: () => _confirmDeletion(habit),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("TERMINAR PROTOCOLO?", 
          style: TextStyle(color: colorDanger, fontSize: 16, fontWeight: FontWeight.w900)),
        content: Text("Isso removerá '${habit.title}' da sua rotina ativa. Confirmar operação?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadAllData(); // Recarrega para cancelar o arraste visual se necessário
            }, 
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              activeHabits.removeWhere((h) => h.id == habit.id);
              await StorageService.saveActiveHabits(activeHabits);
              Navigator.pop(context);
              _loadAllData();
            },
            child: const Text("CONFIRMAR", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}