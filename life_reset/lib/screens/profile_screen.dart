import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui'; // Para o efeito de Blur
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/level_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // PALETA CYBER-TECH PADRONIZADA
  final Color colorBackground = const Color(0xFF0A0A0A);
  final Color colorAccent = const Color(0xFFD0FF00); // Verde Ácido
  final Color colorPrimary = const Color(0xFF8116E0); // Roxo
  final Color colorSurface = const Color(0xFF121212);
  final Color colorText = const Color(0xFFFEFFFC);

  String userName = "";
  String? imagePath;
  int totalXp = 0;
  Map<String, double> bodyStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final name = await StorageService.loadUserName();
    final img = await StorageService.loadProfileImage();
    final xp = await LevelService.getTotalXp();
    final stats = await StorageService.loadBodyStats();

    setState(() {
      userName = name;
      imagePath = img;
      totalXp = xp;
      bodyStats = stats ?? {};
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        await StorageService.saveProfileImage(pickedFile.path);
        setState(() => imagePath = pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFFF0055),
          content: Text("ERRO AO ACESSAR GALERIA: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int level = LevelService.getLevel(totalXp);
    
    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        title: const Text("SISTEMA_ID", style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: colorAccent))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // AVATAR COM EFEITO DE PROFUNDIDADE
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorPrimary.withOpacity(0.5), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: colorSurface,
                            backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
                            child: imagePath == null 
                                ? Icon(Icons.person_add_alt_1, color: colorAccent, size: 35) 
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: colorAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // NOME EDITÁVEL COM ESTILO MINIMALISTA
                TextField(
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorText, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
                  decoration: InputDecoration(
                    hintText: userName.isEmpty ? "USUÁRIO" : userName,
                    hintStyle: const TextStyle(color: Colors.white10),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) async {
                    if (val.isNotEmpty) {
                      await StorageService.saveUserName(val);
                      setState(() => userName = val);
                    }
                  },
                ),
                
                Text("LEVEL $level", style: TextStyle(color: colorAccent, letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 11)),
                
                const SizedBox(height: 48),
                
                // GRID DE BIOMETRIA (GLASSMORPHISM)
                _buildInfoTile("PESO ATUAL", "${bodyStats['peso'] ?? 75.0} kg"),
                _buildInfoTile("ESTATURA", "1.61 m"),
                _buildInfoTile("CINTURA", "${bodyStats['cintura'] ?? '--'} cm"),
                _buildInfoTile("COXAS", "${bodyStats['coxas'] ?? '--'} cm"),
                
                const SizedBox(height: 30),
                Text(
                  "DADOS SINCRONIZADOS LOCALMENTE", 
                  style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: colorSurface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.03)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label, 
                  style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)
                ),
                Text(
                  value, 
                  style: TextStyle(color: colorAccent, fontWeight: FontWeight.w900, fontSize: 15)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}