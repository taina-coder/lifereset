import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/attribute_stats.dart';
import '../services/storage_service.dart';
import '../services/level_service.dart'; 

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  // PALETA CYBER-TECH EXPANDIDA (Cores exclusivas para cada categoria)
  final Color colorAccent = const Color(0xFFD0FF00);       // Verde Neon
  final Color colorAccentDark = const Color(0xFF88A600);   // Verde Tech
  final Color colorAccentLight = const Color(0xFFE8FF80);  // Verde Menta
  
  final Color colorPrimary = const Color(0xFF8116E0);      // Roxo Original
  final Color colorPrimaryLight = const Color(0xFFA64DFF); // Roxo Neon
  final Color colorPrimarySuperLight = const Color(0xFFD9B3FF); // Lilás
  
  final Color colorSurface = const Color(0xFF121212);

  AttributeStats stats = AttributeStats();
  bool isLoading = true;
  int totalXp = 0; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Carrega os atributos preservando os dados existentes
    final loadedStats = await StorageService.loadAttributeStats();
    // Busca o XP global para sincronia total com a Home
    final xp = await LevelService.getTotalXp(); 
    
    setState(() {
      stats = loadedStats;
      totalXp = xp; 
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(backgroundColor: Color(0xFF0A0A0A), body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), 
      appBar: AppBar(
        title: const Text("STATUS_DO_SISTEMA", 
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildMainLevelCard(),
              const SizedBox(height: 32),
              
              // SEÇÃO 1: CORPO E VITALIDADE
              _buildAttributeSection("CORPO & VITALIDADE", [
                _buildStatBar("FÍSICO", stats.physique, colorAccent),
                _buildStatBar("ESTAMINA", stats.stamina, colorAccentDark),
                _buildStatBar("SAÚDE", stats.health, Colors.white),
              ]),
              
              const SizedBox(height: 24),
              
              // SEÇÃO 2: MENTE E COGNIÇÃO
              _buildAttributeSection("MENTE & COGNIÇÃO", [
                _buildStatBar("INTELIGÊNCIA", stats.intellect, colorPrimaryLight),
                _buildStatBar("SANIDADE", stats.sanity, colorPrimary),
              ]),

              const SizedBox(height: 24),
              
              // SEÇÃO 3: IMAGEM E PRESENÇA
              _buildAttributeSection("IMAGEM & PRESENÇA", [
                _buildStatBar("APARÊNCIA", stats.appearance, colorAccentLight),
                _buildStatBar("AUTOESTIMA", stats.selfEsteem, colorPrimarySuperLight),
              ]),

              const SizedBox(height: 24),

              // SEÇÃO 4: IMPACTO EXTERNO
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
            border: Border.all(color: colorPrimary.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text("LEVEL", style: TextStyle(color: colorPrimary, fontWeight: FontWeight.bold, letterSpacing: 5)),
              Text("$level", style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress, 
                backgroundColor: Colors.white.withOpacity(0.05),
                color: colorAccent, 
                minHeight: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeSection(String title, List<Widget> statsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 16),
        ...statsList,
      ],
    );
  }

  Widget _buildStatBar(String label, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.05),
                color: color,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}