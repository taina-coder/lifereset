// ignore_for_file: unused_import

import '../models/task.dart';
import '../models/habit.dart';

class HabitCatalog {
  static List<Habit> getAvailableHabits() {
    return [
      _buildHabit(
        id: 'estudos_aws',
        title: 'AWS Developer Associate',
        category: 'TECH',
        duration: '30 DIAS',
        imageUrl: 'assets/images/estudosaws.png',
        desc: 'Cronograma de 30 dias cobrindo de IAM até CI/CD.',
        study: 'Certificações aumentam a retenção prática em 60%.',
        fit: 98,
        benefits: [
          HabitBenefit(label: 'Carreira', bonusValue: 25, iconType: 'work'),
          HabitBenefit(label: 'Inteligência', bonusValue: 15, iconType: 'psychology'),
        ],
      ),
      _buildHabit(
        id: 'treino_hibrido',
        title: 'Treino Híbrido',
        category: 'FÍSICO',
        duration: '30 DIAS',
        imageUrl: 'assets/images/treino.png',
        desc: 'Escala semanal variada: Push, Pull, Legs e Cardio.',
        study: 'O treinamento de força reduz a mortalidade em 23%.',
        fit: 95,
        benefits: [
          HabitBenefit(label: 'Força', bonusValue: 20, iconType: 'fitness_center'),
          HabitBenefit(label: 'Stamina', bonusValue: 15, iconType: 'directions_run'),
        ],
      ),
      _buildHabit(
        id: 'skincare_rotina',
        title: 'Skincare',
        category: 'SAÚDE',
        duration: '30 DIAS',
        imageUrl: 'assets/images/skincare.png',
        desc: 'Mantenha a saúde da barreira cutânea.',
        study: 'O uso de protetor solar reduz o envelhecimento em 24%.',
        fit: 85,
        benefits: [
          HabitBenefit(label: 'Aparência', bonusValue: 15, iconType: 'face_retouching_natural'),
          HabitBenefit(label: 'Autoestima', bonusValue: 20, iconType: 'face'),
        ],
        tasks: [
          Task(title: 'Limpeza dupla', impactTag: 'SAÚDE', xpValue: 5),
          Task(title: 'Hidratante', impactTag: 'SAÚDE', xpValue: 10),
          Task(title: 'Acido', impactTag: 'SAÚDE', xpValue: 10),
          Task(title: 'Protetor solar', impactTag: 'SAÚDE', xpValue: 5),
        ],
      ),
      _buildHabit(
        id: 'sono_qualidade',
        title: 'Sono Limpo',
        category: 'SAÚDE',
        duration: '30 DIAS',
        imageUrl: 'assets/images/dormir.png',
        desc: 'Regule seu ciclo circadiano.',
        study: 'A privação de sono afeta a decisão como a embriaguez.',
        fit: 92,
        benefits: [
          HabitBenefit(label: 'Saúde', bonusValue: 20, iconType: 'health_and_safety'),
          HabitBenefit(label: 'Sanidade', bonusValue: 25, iconType: 'spa'),
        ],
        tasks: [
          Task(title: 'Sem telas 1h antes de deitar', impactTag: 'SANIDADE', xpValue: 15),
          Task(title: 'Dormir às 9h', impactTag: 'SAÚDE', xpValue: 10),
          Task(title: 'Acordar às 5h', impactTag: 'SAÚDE', xpValue: 10),
          Task(title: 'Tomar Melatonina', impactTag: 'SAÚDE', xpValue: 10),
          Task(title: 'Rastreador de sono e ruído branco', impactTag: 'SAÚDE', xpValue: 10),
        ],
      ),
      _buildHabit(
        id: 'meditacao_profunda',
        title: 'Meditação',
        category: 'MENTAL',
        duration: '30 DIAS',
        imageUrl: 'assets/images/meditacao.png',
        desc: 'Reduza o ruído mental.',
        study: 'Mindfulness aumenta densidade de massa cinzenta.',
        fit: 88,
        benefits: [
          HabitBenefit(label: 'Saúde', bonusValue: 10, iconType: 'healing'),
          HabitBenefit(label: 'Sanidade', bonusValue: 30, iconType: 'self_improvement'),
        ],
        tasks: [
          Task(title: '10 minutos de foco na respiração', impactTag: 'SANIDADE', xpValue: 10),
        ],
      ),
      _buildHabit(
        id: 'vicio_fast_food',
        title: 'Sem Fast Food',
        category: 'SAÚDE',
        duration: '30 DIAS',
        imageUrl: 'assets/images/fastfood.png',
        desc: 'Elimine ultraprocessados e restaure sua dopamina.',
        study: 'Ultraprocessados aceleram o declínio cognitivo em 28%.',
        fit: 85,
        benefits: [
          HabitBenefit(label: 'Saúde', bonusValue: 25, iconType: 'favorite'),
          HabitBenefit(label: 'Aparência', bonusValue: 15, iconType: 'star'),
        ],
        tasks: [
          Task(title: 'Zero delivery de Fast Food hoje', impactTag: 'SAÚDE', xpValue: 15),
          Task(title: 'Não consumir fritura/açúcar refinado', impactTag: 'FÍSICO', xpValue: 15),
          Task(title: 'Não comer entre refeiçções', impactTag: 'FÍSICO', xpValue: 15),
        ],
      ),
      _buildHabit(
        id: 'jornal_diario',
        title: 'Jornal',
        category: 'MENTAL',
        duration: '30 DIAS',
        imageUrl: 'assets/images/jornal.png',
        desc: 'Escrita terapêutica para organizar metas.',
        study: 'Escrever sobre emoções melhora a imunidade.',
        fit: 80,
        benefits: [
          HabitBenefit(label: 'Sanidade', bonusValue: 20, iconType: 'edit_note'),
          HabitBenefit(label: 'Social', bonusValue: 10, iconType: 'people'),
        ],
        tasks: [
          Task(title: 'Escrever 1 página', impactTag: 'INTELIGENCIA', xpValue: 10),
        ],
      ),
    ];
  }

  static Habit _buildHabit({
    required String id, required String title, required String category, 
    required String duration, required String imageUrl, required String desc,
    required String study, required int fit, required List<HabitBenefit> benefits,
    List<Task>? tasks,
  }) {
    return Habit(
      id: id, title: title, category: category, duration: duration,
      imageUrl: imageUrl, goalDescription: desc, scientificStudy: study,
      fitPercentage: fit, benefits: benefits, 
      tasks: tasks ?? [], 
    );
  }
}