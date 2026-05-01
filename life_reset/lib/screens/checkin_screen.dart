import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/checkin_service.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  // Paleta seguindo o seu design (Roxo Destaque)
  final Color colorAccent = const Color(0xFF8116E0); 
  final Color colorAccentLight = const Color(0xFFA64DFF);
  final Color colorSurface = const Color(0xFF121212);
  final Color colorBackground = const Color(0xFF0A0A0A);

  int currentStreak = 0;
  List<String> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCheckinData();
  }

  Future<void> _loadCheckinData() async {
    int streak = await CheckinService.getCurrentStreak();
    List<String> dates = await CheckinService.getCheckinHistory();
    
    setState(() {
      currentStreak = streak;
      history = dates;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(backgroundColor: colorBackground, body: Center(child: CircularProgressIndicator(color: colorAccent)));

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text("SISTEMA DE OFENSIVA", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStreakCard(),
            const SizedBox(height: 32),
            _buildCalendar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: colorAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
        ]
      ),
      child: Column(
        children: [
          Icon(Icons.local_fire_department, color: colorAccentLight, size: 48),
          const SizedBox(height: 16),
          const Text("OFENSIVA ATUAL", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text("$currentStreak DIAS", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white54),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white54),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.white54),
          outsideDaysVisible: false,
          // Estilo do dia de hoje (apenas contorno)
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: colorAccent.withOpacity(0.5), width: 2),
          ),
          // Estilo dos dias em que houve check-in (Preenchido com o seu Roxo)
          selectedDecoration: BoxDecoration(
            color: colorAccent,
            shape: BoxShape.circle,
          ),
        ),
        // A mágica acontece aqui: Pinta o dia se ele estiver na nossa lista de histórico
        selectedDayPredicate: (day) {
          String formattedDay = day.toIso8601String().split('T')[0];
          return history.contains(formattedDay);
        },
      ),
    );
  }
}