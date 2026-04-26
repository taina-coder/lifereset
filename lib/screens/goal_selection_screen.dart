import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/habit.dart';
import '../data/habit_catalog.dart' as catalog;
import '../services/storage_service.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  // PALETA CYBER-TECH PADRONIZADA
  final Color colorBackground = const Color(0xFF0A0A0A);
  final Color colorAccent = const Color(0xFFD0FF00); // Verde Ácido
  final Color colorSurface = const Color(0xFF121212);

  List<Habit> availableHabits = [];
  Set<String> selectedIds = {};
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final habits = catalog.HabitCatalog.getAvailableHabits();
    final active = await StorageService.loadActiveHabits();
    
    setState(() {
      availableHabits = habits; 
      selectedIds = active.map((h) => h.id).toSet();
      isLoading = false;
    });
  }

  void _saveAndExit() async {
    List<Habit> habitsToSave = [];
    final allHabits = catalog.HabitCatalog.getAvailableHabits();
    
    for (String id in selectedIds) {
      try {
        habitsToSave.add(allHabits.firstWhere((h) => h.id == id));
      } catch (e) {
        debugPrint("Erro ao localizar protocolo: $e");
      }
    }
    
    await StorageService.saveActiveHabits(habitsToSave);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text("SWAP PROTOCOLOS", 
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: colorAccent),
            onPressed: _saveAndExit,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorAccent))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTopProgress(),
                  const Spacer(),
                  
                  if (currentIndex < availableHabits.length)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: Dismissible(
                        key: Key(availableHabits[currentIndex].id),
                        onDismissed: (direction) {
                          setState(() {
                            if (direction == DismissDirection.startToEnd) {
                              selectedIds.add(availableHabits[currentIndex].id);
                            } else {
                              selectedIds.remove(availableHabits[currentIndex].id);
                            }
                            currentIndex++;
                          });
                          
                          if (currentIndex >= availableHabits.length) {
                            _saveAndExit();
                          }
                        },
                        background: _buildSwipeBackground(Alignment.centerLeft, colorAccent, Icons.add_circle),
                        secondaryBackground: _buildSwipeBackground(Alignment.centerRight, Colors.white24, Icons.close),
                        child: _buildHabitCard(availableHabits[currentIndex]),
                      ),
                    )
                  else
                    const Center(child: Text("SISTEMA SINCRONIZADO", 
                      style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 2))),

                  const Spacer(),
                  _buildBottomCounter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTopProgress() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: availableHabits.isEmpty ? 0 : (currentIndex + 1) / availableHabits.length,
            backgroundColor: Colors.white10,
            color: colorAccent,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "PROTOCOL ${currentIndex + 1} OF ${availableHabits.length}",
          style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildHabitCard(Habit habit) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        image: DecorationImage(
          image: AssetImage(habit.imageUrl ?? ''),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
              ),
            ),
          ),
          
          Positioned(
            bottom: 20, left: 15, right: 15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white.withOpacity(0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rótulos Semânticos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCategoryBadge(habit.category), // ex: TECH, FÍSICO
                          _buildDurationBadge(habit.duration), // ex: 30 DIAS
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(habit.title.toUpperCase(), 
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                      
                      if (habit.goalDescription != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            habit.goalDescription!,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.3),
                          ),
                        ),

                      const SizedBox(height: 12),
                      // Badges de Atributos RPG
                      Row(
                        children: (habit.benefits).map((b) => _buildAttributeBadge(b)).toList(),
                      ),
                      
                      const SizedBox(height: 15),
                      if (habit.scientificStudy != null) _buildStudyBox(habit.scientificStudy!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: colorAccent, 
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      category.toUpperCase(),
      style: TextStyle( // Removido o 'const' daqui
        color: Colors.black, 
        fontSize: 10, 
        fontWeight: FontWeight.w900, // Alterado de .black para .w900
        letterSpacing: 1,
      ),
    ),
  );
}

  Widget _buildDurationBadge(String duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        duration.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAttributeBadge(HabitBenefit benefit) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(benefit.label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
          Text("+${benefit.bonusValue}%", style: TextStyle(color: colorAccent, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStudyBox(String study) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(study, style: const TextStyle(color: Colors.white70, fontSize: 10, height: 1.4)),
    );
  }

  Widget _buildSwipeBackground(Alignment align, Color color, IconData icon) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
      child: Icon(icon, color: color, size: 50),
    );
  }

  Widget _buildBottomCounter() {
    return Text("${selectedIds.length} PROTOCOLOS ATIVOS", 
      style: TextStyle(color: colorAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1));
  }
}