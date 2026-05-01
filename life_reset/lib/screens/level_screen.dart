import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart'; 
import '../models/attribute_stats.dart';
import '../services/storage_service.dart';
import '../services/level_service.dart'; 

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  // Paleta Cyber-Tech
  final Color colorAccent = const Color(0xFF8116E0);       
  final Color colorAccentLight = const Color(0xFFA64DFF);  
  final Color colorPrimary = const Color(0xFFD0FF00);      
  
  final Color colorSurface = const Color(0xFF121212);
  final Color colorBackground = const Color(0xFF0A0A0A);

  // CONFIGURAÇÕES DE LEVEL DOS ATRIBUTOS
  final int maxAttributeLevel = 50;
  final double xpPerAttributeLevel = 150.0;

  AttributeStats stats = AttributeStats();
  bool isLoading = true;
  int totalXp = 0; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedStats = await StorageService.loadAttributeStats();
    final xp = await LevelService.getTotalXp(); 
    
    setState(() {
      stats = loadedStats;
      totalXp = xp; 
      isLoading = false;
    });
  }

  // Lógica de Nível para os Atributos (Converte o XP bruto em Nível - Inteiro)
  int _getAttributeLevel(double rawXp) {
    int lvl = (rawXp / xpPerAttributeLevel).floor() + 1;
    return lvl > maxAttributeLevel ? maxAttributeLevel : lvl;
  }

  // Retorna o nível com os decimais do progresso atual (ex: 1.5) para o gráfico crescer suavemente
  double _getExactAttributeLevel(double rawXp) {
    double exactLevel = (rawXp / xpPerAttributeLevel) + 1.0;
    return exactLevel > maxAttributeLevel ? maxAttributeLevel.toDouble() : exactLevel;
  }

  // Lógica da barra de progresso do Atributo até o PRÓXIMO nível
  double _getAttributeProgress(double rawXp) {
    if (_getAttributeLevel(rawXp) >= maxAttributeLevel) return 1.0;
    return (rawXp % xpPerAttributeLevel) / xpPerAttributeLevel;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(backgroundColor: colorBackground, body: Center(child: CircularProgressIndicator(color: colorAccent)));

    return Scaffold(
      backgroundColor: colorBackground, 
      appBar: AppBar(
        title: const Text("STATUS_DO_SISTEMA", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: colorAccent,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildMainLevelCard(),
              const SizedBox(height: 32),
              _buildRadarChartSection(),
              const SizedBox(height: 32),
              
              _buildAttributeSection("CORPO & VITALIDADE", [
                _buildStatBar("FÍSICO", stats.physique, colorAccent),
                _buildStatBar("ESTAMINA", stats.stamina, const Color(0xFF4D0099)), 
                _buildStatBar("SAÚDE", stats.health, Colors.white),
              ]),
              
              const SizedBox(height: 24),
              _buildAttributeSection("MENTE & COGNIÇÃO", [
                _buildStatBar("INTELIGÊNCIA", stats.intellect, colorPrimary), 
                _buildStatBar("SANIDADE", stats.sanity, colorPrimary),
              ]),

              const SizedBox(height: 24),
              _buildAttributeSection("IMAGEM & PRESENÇA", [
                _buildStatBar("APARÊNCIA", stats.appearance, const Color(0xFFD9B3FF)), 
                _buildStatBar("AUTOESTIMA", stats.selfEsteem, const Color(0xFFD9B3FF)),
              ]),

              const SizedBox(height: 24),
              _buildAttributeSection("IMPACTO EXTERNO", [
                _buildStatBar("CARREIRA", stats.career, Colors.grey[400]!),
                _buildStatBar("SOCIAL", stats.social, Colors.grey[700]!),
              ]),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainLevelCard() {
    int level = LevelService.getLevel(totalXp);
    double progress = LevelService.getLevelProgress(totalXp);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: colorAccent.withOpacity(0.3)), 
          ),
          child: Column(
            children: [
              Text("GLOBAL LEVEL", style: TextStyle(color: colorAccent, fontWeight: FontWeight.bold, letterSpacing: 5)),
              Text("$level", style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.05), color: colorAccentLight, minHeight: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("MAPA DE ATRIBUTOS (LVL MAX 50)", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 24),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: colorSurface, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withOpacity(0.02))),
          child: RadarChart(
            RadarChartData(
              radarBorderData: const BorderSide(color: Colors.transparent),
              gridBorderData: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
              tickBorderData: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
              tickCount: 5, 
              ticksTextStyle: const TextStyle(color: Colors.transparent), 
              titlePositionPercentageOffset: 0.15, 
              titleTextStyle: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              getTitle: (index, angle) {
                switch (index) {
                  case 0: return const RadarChartTitle(text: 'FÍSICO');
                  case 1: return const RadarChartTitle(text: 'SANIDADE');
                  case 2: return const RadarChartTitle(text: 'AUTOESTIMA');
                  case 3: return const RadarChartTitle(text: 'SOCIAL');
                  case 4: return const RadarChartTitle(text: 'INTELECTO');
                  case 5: return const RadarChartTitle(text: 'VITALIDADE');
                  default: return const RadarChartTitle(text: '');
                }
              },
              dataSets: [
                // DATASET INVISÍVEL: Trava a teia para que o teto seja sempre Level 50
                RadarDataSet(
                  fillColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  entryRadius: 0,
                  dataEntries: [
                    RadarEntry(value: maxAttributeLevel.toDouble()), 
                    RadarEntry(value: maxAttributeLevel.toDouble()), 
                    RadarEntry(value: maxAttributeLevel.toDouble()),
                    RadarEntry(value: maxAttributeLevel.toDouble()), 
                    RadarEntry(value: maxAttributeLevel.toDouble()), 
                    RadarEntry(value: maxAttributeLevel.toDouble()),
                  ],
                ),
                // DATASET REAL: Com a sua evolução verdadeira
                RadarDataSet(
                  fillColor: colorAccent.withOpacity(0.3), 
                  borderColor: colorAccentLight,           
                  borderWidth: 3,
                  entryRadius: 4,                          
                  dataEntries: [
                    RadarEntry(value: _getExactAttributeLevel(stats.physique)),
                    RadarEntry(value: _getExactAttributeLevel(stats.sanity)),
                    RadarEntry(value: _getExactAttributeLevel(stats.selfEsteem)),
                    RadarEntry(value: _getExactAttributeLevel(stats.social)),
                    RadarEntry(value: _getExactAttributeLevel(stats.intellect)),
                    RadarEntry(value: _getExactAttributeLevel(stats.health)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeSection(String title, List<Widget> statsList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
      const SizedBox(height: 16),
      ...statsList,
    ]);
  }

  Widget _buildStatBar(String label, double rawXp, Color color) {
    int currentLevel = _getAttributeLevel(rawXp);
    double progressToNextLevel = _getAttributeProgress(rawXp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text("$label LVL.$currentLevel", style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progressToNextLevel, backgroundColor: Colors.white.withOpacity(0.05), color: color, minHeight: 8),
            ),
          ),
          const SizedBox(width: 12),
          Text("${(progressToNextLevel * 100).toInt()}%", style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}