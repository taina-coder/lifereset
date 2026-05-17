import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/exercise_load_record.dart';
import '../services/exercise_load_service.dart';

class ExerciseLoadScreen extends StatefulWidget {
  const ExerciseLoadScreen({super.key});

  @override
  State<ExerciseLoadScreen> createState() => _ExerciseLoadScreenState();
}

class _ExerciseLoadScreenState extends State<ExerciseLoadScreen> {
  final Color colorBackground = const Color(0xFF0A0A0A);
  final Color colorAccent = const Color(0xFFD0FF00);
  final Color colorPrimary = const Color(0xFF8116E0);
  final Color colorSurface = const Color(0xFF121212);
  final Color colorText = const Color(0xFFFEFFFC);

  bool isLoading = true;
  List<ExerciseLoadRecord> records = [];
  String? selectedExercise;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await ExerciseLoadService.loadHistory();
    final exercises = _exerciseNames(history);
    setState(() {
      records = history;
      selectedExercise = exercises.contains(selectedExercise)
          ? selectedExercise
          : (exercises.isEmpty ? null : exercises.first);
      isLoading = false;
    });
  }

  List<String> _exerciseNames(List<ExerciseLoadRecord> source) {
    final names = source.map((record) => record.exerciseName).toSet().toList();
    names.sort();
    return names;
  }

  List<ExerciseLoadRecord> get selectedRecords {
    final exercise = selectedExercise;
    if (exercise == null) return [];
    return records.where((record) => record.exerciseName == exercise).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: colorBackground,
        body: Center(child: CircularProgressIndicator(color: colorAccent)),
      );
    }

    final exercises = _exerciseNames(records);

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text(
          "CARGAS",
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: records.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExercisePicker(exercises),
                  const SizedBox(height: 24),
                  _buildSummary(selectedRecords),
                  const SizedBox(height: 24),
                  _buildChart(selectedRecords),
                  const SizedBox(height: 28),
                  const Text(
                    "HISTORICO",
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...selectedRecords.reversed.map(_buildHistoryRow),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: colorPrimary, size: 56),
            const SizedBox(height: 20),
            const Text(
              "SEM CARGAS REGISTRADAS",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ao concluir uma tarefa de treino, registre a carga levantada para criar sua linha de evolucao.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisePicker(List<String> exercises) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedExercise,
          isExpanded: true,
          dropdownColor: colorSurface,
          icon: Icon(Icons.keyboard_arrow_down, color: colorAccent),
          style: TextStyle(color: colorText, fontWeight: FontWeight.bold),
          items: exercises
              .map(
                (exercise) => DropdownMenuItem(
                  value: exercise,
                  child: Text(exercise, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => selectedExercise = value),
        ),
      ),
    );
  }

  Widget _buildSummary(List<ExerciseLoadRecord> source) {
    final latest = source.last;
    final first = source.first;
    final best = source
        .map((record) => record.loadKg)
        .reduce((a, b) => a > b ? a : b);
    final change = latest.loadKg - first.loadKg;

    return Row(
      children: [
        Expanded(child: _buildMetricCard("ULTIMA", "${_formatLoad(latest.loadKg)} KG")),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard("MELHOR", "${_formatLoad(best)} KG")),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            "VARIACAO",
            "${change >= 0 ? '+' : ''}${_formatLoad(change)} KG",
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorAccent.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: colorAccent,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<ExerciseLoadRecord> source) {
    final spots = [
      for (int i = 0; i < source.length; i++)
        FlSpot(i.toDouble(), source[i].loadKg),
    ];
    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    double padding = (maxY - minY) * 0.2;
    if (padding == 0) padding = 5;

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorPrimary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "EVOLUCAO DE CARGA",
            style: TextStyle(
              color: colorAccent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: (minY - padding).clamp(0, double.infinity).toDouble(),
                maxY: maxY + padding,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        _formatLoad(value),
                        style: const TextStyle(color: Colors.white30, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: source.length > 6 ? (source.length / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= source.length) {
                          return const SizedBox.shrink();
                        }
                        final date = source[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(color: Colors.white30, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: colorAccent,
                    barWidth: 4,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: colorAccent,
                        strokeWidth: 2,
                        strokeColor: colorSurface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorAccent.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(ExerciseLoadRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: colorPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${record.date.day.toString().padLeft(2, '0')}/${record.date.month.toString().padLeft(2, '0')}/${record.date.year}',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            "${_formatLoad(record.loadKg)} KG",
            style: TextStyle(color: colorAccent, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  String _formatLoad(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}
