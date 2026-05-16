import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_load.dart';

class ExerciseLoadScreen extends StatefulWidget {
  const ExerciseLoadScreen({super.key});

  @override
  State<ExerciseLoadScreen> createState() => _ExerciseLoadScreenState();
}

class _ExerciseLoadScreenState extends State<ExerciseLoadScreen> {
  // PALETA CYBER-TECH PADRONIZADA
  final Color colorBackground = const Color(0xFF0A0A0A);
  final Color colorAccent = const Color(0xFFD0FF00);
  final Color colorPrimary = const Color(0xFF8116E0);
  final Color colorSurface = const Color(0xFF121212);

  // Mapa onde a chave é o nome do exercício e o valor é a lista de cargas dele
  Map<String, List<ExerciseLoad>> _groupedHistory = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDynamicHistory();
  }

  // Lê tudo do banco local e agrupa dinamicamente
  Future<void> _loadDynamicHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? historyJson = prefs.getString('exercise_load_history');
    Map<String, List<ExerciseLoad>> grouped = {};

    if (historyJson != null) {
      List<dynamic> historyList = jsonDecode(historyJson);
      
      for (var item in historyList) {
        ExerciseLoad load = ExerciseLoad.fromMap(item as Map<String, dynamic>);
        
        if (!grouped.containsKey(load.exerciseName)) {
          grouped[load.exerciseName] = [];
        }
        grouped[load.exerciseName]!.add(load);
      }
    }

    // Ordena as listas por data para o gráfico não bugar
    grouped.forEach((key, list) {
      list.sort((a, b) => a.date.compareTo(b.date));
    });

    setState(() {
      _groupedHistory = grouped;
      isLoading = false;
    });
  }

  // Função para injetar dados falsos para teste
  Future<void> _injectTestData() async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> historyList = [];
    
    // Mantém o que já existe
    String? existingJson = prefs.getString('exercise_load_history');
    if (existingJson != null) {
      historyList = jsonDecode(existingJson);
    }

    // Gera 5 dias de dados falsos crescentes
    DateTime now = DateTime.now();
    List<double> fakeWeights = [30.0, 32.5, 32.5, 35.0, 37.5];
    
    for (int i = 0; i < 5; i++) {
      historyList.add({
        'exerciseName': 'Agachamento Teste (Debug)',
        'weight': fakeWeights[i],
        'date': now.subtract(Duration(days: 14 - (i * 3))).toIso8601String(), // Datas passadas
      });
    }

    await prefs.setString('exercise_load_history', jsonEncode(historyList));
    await _loadDynamicHistory(); // Recarrega a tela com os novos dados
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dados de teste injetados com sucesso!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: colorPrimary,
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  // Função para limpar TODO o histórico de cargas
  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exercise_load_history');
    await _loadDynamicHistory();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histórico resetado.'), backgroundColor: Colors.redAccent)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text("DIÁRIO DE CARGA", 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Botão de Debug para Injetar Dados (Customizado com GestureDetector)
          GestureDetector(
            onTap: _injectTestData,
            child: Container(
              color: Colors.transparent, // Área clicável transparente
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Espaçamento para não ficar espremido
              child: const Icon(Icons.bug_report, color: Colors.white54, size: 24),
            ),
          ),
          
          // Botão para limpar a base de testes (Customizado com GestureDetector)
          GestureDetector(
            onTap: _clearAllData,
            child: Container(
              color: Colors.transparent, 
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Icon(Icons.delete_sweep, color: Colors.white54, size: 24),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorAccent))
          : _groupedHistory.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _groupedHistory.keys.length,
                  itemBuilder: (context, index) {
                    String exerciseName = _groupedHistory.keys.elementAt(index);
                    List<ExerciseLoad> history = _groupedHistory[exerciseName]!;
                    
                    double lastWeight = history.last.weight;

                    return _buildExpandableExerciseCard(exerciseName, lastWeight, history);
                  },
                ),
    );
  }

  Widget _buildExpandableExerciseCard(String exerciseName, double lastWeight, List<ExerciseLoad> history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: colorAccent,
          collapsedIconColor: Colors.white54,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            exerciseName.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "Última carga: $lastWeight kg",
              style: TextStyle(color: colorAccent.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.only(right: 24, left: 16, top: 16, bottom: 24),
              child: _buildChart(history),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<ExerciseLoad> history) {
    if (history.length == 1) {
      return Center(
        child: Text("Anote a carga no próximo treino para gerar o gráfico!", 
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true, 
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < history.length) {
                  DateTime date = history[index].date;
                  String dateStr = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(dateStr, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}kg', 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: history.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.weight);
            }).toList(),
            isCurved: true,
            color: colorPrimary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4, color: colorPrimary, strokeWidth: 1, strokeColor: colorSurface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorPrimary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 60, color: colorPrimary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text("NENHUMA CARGA REGISTRADA", 
            style: TextStyle(color: colorPrimary.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text("Registre pesos na aba inicial para\nacompanhar sua evolução aqui.", 
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10)),
        ],
      ),
    );
  }
}