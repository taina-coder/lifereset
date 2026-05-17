import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../services/storage_service.dart';
import '../services/local_database_service.dart';

class BodyStatsScreen extends StatefulWidget {
  const BodyStatsScreen({super.key});

  @override
  State<BodyStatsScreen> createState() => _BodyStatsScreenState();
}

class _BodyStatsScreenState extends State<BodyStatsScreen> {
  // PALETA CYBER-TECH
  final Color colorBackground = const Color(0xFF0A0A0A);
  final Color colorAccent = const Color(0xFFD0FF00);      // Verde Neon (Peso)
  final Color colorPrimary = const Color(0xFF8116E0);     // Roxo (Cintura)
  final Color colorCyan = const Color(0xFF00E5FF);        // Ciano (Coxas)
  final Color colorMagenta = const Color(0xFFFF0055);     // Magenta (Peito)
  final Color colorSurface = const Color(0xFF121212);
  final Color colorText = const Color(0xFFFEFFFC);

  // Controladores para os inputs
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _thighsController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();

  bool isLoading = true;
  
  // Lista que vai guardar a evolução das suas medidas
  List<Map<String, dynamic>> statsHistory = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentStats();
  }

  /// Carrega as medidas salvas e o histórico do gráfico
  Future<void> _loadCurrentStats() async {
    final String? historyJson =
        await LocalDatabaseService.getValue<String>('body_stats_history');
    
    if (historyJson != null) {
      List<dynamic> decoded = jsonDecode(historyJson);
      statsHistory = decoded.cast<Map<String, dynamic>>();
    }

    // Se houver histórico, preenche os inputs com o dado mais recente
    if (statsHistory.isNotEmpty) {
      final latest = statsHistory.last;
      setState(() {
        _weightController.text = latest['peso']?.toString() ?? '';
        _waistController.text = latest['cintura']?.toString() ?? '';
        _thighsController.text = latest['coxas']?.toString() ?? '';
        _chestController.text = latest['peito']?.toString() ?? '';
      });
    } else {
      // Fallback para o StorageService antigo caso seja o primeiro acesso
      final stats = await StorageService.loadBodyStats();
      if (stats != null) {
        setState(() {
          _weightController.text = stats['peso']?.toString() ?? '';
          _waistController.text = stats['cintura']?.toString() ?? '';
          _thighsController.text = stats['coxas']?.toString() ?? '';
          _chestController.text = stats['peito']?.toString() ?? '';
        });
      }
    }
    
    setState(() => isLoading = false);
  }

  /// Salva as medidas atuais e adiciona ao gráfico de histórico
  Future<void> _saveStats() async {
    Map<String, double> currentStats = {
      'peso': double.tryParse(_weightController.text) ?? 0.0,
      'cintura': double.tryParse(_waistController.text) ?? 0.0,
      'coxas': double.tryParse(_thighsController.text) ?? 0.0,
      'peito': double.tryParse(_chestController.text) ?? 0.0,
    };

    // Salva o atual (mantém a compatibilidade com a tela de perfil)
    await StorageService.saveBodyStats(currentStats);
    
    // Atualiza o histórico para o Gráfico
    String today = DateTime.now().toString().split(' ')[0]; // Data de hoje: YYYY-MM-DD
    
    int index = statsHistory.indexWhere((e) => e['date'] == today);
    Map<String, dynamic> newEntry = {
      'date': today,
      'peso': currentStats['peso'],
      'cintura': currentStats['cintura'],
      'coxas': currentStats['coxas'],
      'peito': currentStats['peito'],
    };

    if (index >= 0) {
      statsHistory[index] = newEntry; // Sobrescreve se já salvou hoje
    } else {
      statsHistory.add(newEntry);     // Adiciona novo dia
    }

    // Ordena por data (para o gráfico não bugar se o tempo passar)
    statsHistory.sort((a, b) => a['date'].compareTo(b['date']));
    await LocalDatabaseService.setValue(
      'body_stats_history',
      jsonEncode(statsHistory),
    );

    setState(() {}); // Atualiza os gráficos na tela

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: colorAccent,
          content: const Text("MÉTRICAS E HISTÓRICO ATUALIZADOS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    }
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
        title: const Text("BODY STATS", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD DE PESO (DESTAQUE)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorAccent.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PESO ATUAL (KG)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: colorAccent, fontSize: 42, fontWeight: FontWeight.w900),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "00.0",
                      hintStyle: TextStyle(color: Colors.white10),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text("MEDIDAS (CM)", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),

            // INPUTS DE MEDIDAS
            _buildStatInput("Cintura", _waistController),
            _buildStatInput("Coxas", _thighsController),
            _buildStatInput("Peito", _chestController),

            const SizedBox(height: 32),

            // BOTÃO SALVAR
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saveStats,
                child: const Text("SALVAR EVOLUÇÃO", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),

            const SizedBox(height: 48),

            // SEÇÃO DE GRÁFICOS DE EVOLUÇÃO
            if (statsHistory.isNotEmpty) ...[
              const Text("EVOLUÇÃO DO SISTEMA", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 24),
              
              _buildEvolutionChart("PESO CORPORAL (KG)", "peso", colorAccent),
              _buildEvolutionChart("CINTURA (CM)", "cintura", colorPrimary),
              _buildEvolutionChart("COXAS (CM)", "coxas", colorCyan),
              _buildEvolutionChart("PEITO (CM)", "peito", colorMagenta),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatInput(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: TextStyle(color: colorText, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "00",
                hintStyle: TextStyle(color: Colors.white10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET DO GRÁFICO (FL_CHART)
  Widget _buildEvolutionChart(String title, String dataKey, Color chartColor) {
    // Filtra pontos com valor zero para não quebrar o visual do gráfico
    List<Map<String, dynamic>> validHistory = statsHistory.where((e) => (e[dataKey] ?? 0) > 0).toList();
    if (validHistory.isEmpty) return const SizedBox.shrink();

    List<FlSpot> spots = [];
    for (int i = 0; i < validHistory.length; i++) {
      double val = (validHistory[i][dataKey] ?? 0.0).toDouble();
      spots.add(FlSpot(i.toDouble(), val));
    }

    // Calcula os limites Y para o gráfico não ficar espremido
    double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double padding = (maxY - minY) * 0.2;
    if (padding == 0) padding = 2; // Margem padrão se houver só um valor

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: chartColor.withValues(alpha: 0.1)), // Transparência segura
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: chartColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: minY - padding,
                maxY: maxY + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: chartColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: chartColor.withValues(alpha: 0.1),
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
}
