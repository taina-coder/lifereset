import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../screens/manage_goals_screen.dart';
import '../screens/goal_selection_screen.dart';
import '../screens/body_stats_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/level_screen.dart';
import '../screens/checkin_screen.dart'; // Importação da nova tela de Ofensiva

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String userName = "USUÁRIO";
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await StorageService.loadUserName();
    final img = await StorageService.loadProfileImage();
    setState(() {
      userName = name.isEmpty ? "TAINA OLIVEIRA" : name;
      imagePath = img;
    });
  }

  // Função de navegação fluida com transição de slide e fade
  void _animatedNavigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // Fecha o drawer antes de navegar
    
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color colorPrimary = Color(0xFF8116E0); // Roxo Destaque
    const Color colorAccent = Color(0xFFD0FF00);  // Verde Neon
    const Color colorText = Color(0xFFFEFFFC);

    return Drawer(
      backgroundColor: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A0A),
              border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            currentAccountPicture: GestureDetector(
              onTap: () => _animatedNavigate(context, const ProfileScreen()),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorPrimary, width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF121212),
                  backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
                  child: imagePath == null 
                    ? const Icon(Icons.person, color: colorAccent, size: 40) 
                    : null,
                ),
              ),
            ),
            accountName: Text(
              userName.toUpperCase(),
              style: const TextStyle(
                color: colorText,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 16,
              ),
            ),
            accountEmail: const Text(
              "SISTEMA OPERACIONAL ATIVO",
              style: TextStyle(color: colorPrimary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  label: "PERFIL",
                  onTap: () => _animatedNavigate(context, const ProfileScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.military_tech,
                  label: "LEVEL",
                  onTap: () => _animatedNavigate(context, const LevelScreen()),
                ),
                // ITEM NOVO: Acessar o sistema de Ofensiva/Streak
                _buildDrawerItem(
                  icon: Icons.local_fire_department,
                  label: "OFENSIVA",
                  onTap: () => _animatedNavigate(context, const CheckinScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.home_filled,
                  label: "INÍCIO",
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.add_task,
                  label: "PROTOCOLOS",
                  onTap: () => _animatedNavigate(context, const GoalSelectionScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.straighten,
                  label: "MEDIDAS",
                  onTap: () => _animatedNavigate(context, const BodyStatsScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.insights,
                  label: "GESTÃO",
                  onTap: () => _animatedNavigate(context, const ManageGoalsScreen()),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "LifeReset v1.4.0", // Versão atualizada com Sistema de Ofensiva
              style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 2)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF8116E0), size: 22),
      title: Text(
        label, 
        style: const TextStyle(
          color: Color(0xFFFEFFFC), 
          fontWeight: FontWeight.bold, 
          fontSize: 13,
          letterSpacing: 1.1
        )
      ),
      onTap: onTap,
    );
  }
}