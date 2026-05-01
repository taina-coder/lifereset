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
        tasks: [
          Task(title: 'Tópico AWS do dia', impactTag: 'CARREIRA', xpValue: 15),
          Task(title: 'Revisão/Simulado', impactTag: 'INTELIGÊNCIA', xpValue: 10),
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
          HabitBenefit(label: 'Físico', bonusValue: 30, iconType: 'fitness_center'),
          HabitBenefit(label: 'Saúde', bonusValue: 15, iconType: 'favorite'),
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
          Task(title: 'Não comer entre refeições', impactTag: 'FÍSICO', xpValue: 15),
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
          Task(title: 'Dormir às 21h', impactTag: 'SAÚDE', xpValue: 10),
          Task(title: 'Acordar às 05h', impactTag: 'SAÚDE', xpValue: 10),
          Task(title: 'Tomar melatonina', impactTag: 'SAÚDE', xpValue: 10),
        ],
      ),
      _buildHabit(
        id: 'skin_care',
        title: 'Protocolo de Pele',
        category: 'APARÊNCIA',
        duration: 'CONTÍNUO',
        imageUrl: 'assets/images/skincare.png',
        desc: 'Rotina básica com Retinol e Protetor Solar.',
        study: 'O uso diário de protetor solar reduz o envelhecimento em 24%.',
        fit: 90,
        benefits: [
          HabitBenefit(label: 'Aparência', bonusValue: 25, iconType: 'face'),
          HabitBenefit(label: 'Autoestima', bonusValue: 15, iconType: 'sentiment_very_satisfied'),
        ],
        tasks: [
          Task(title: 'Limpeza dupla', impactTag: 'AUTOESTIMA', xpValue: 15),
          Task(title: 'Hidratante', impactTag: 'AUTOESTIMA', xpValue: 15),
          Task(title: 'Acido', impactTag: 'AUTOESTIMA', xpValue: 15),
          Task(title: 'Protetor solar', impactTag: 'AUTOESTIMA', xpValue: 15),
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
          Task(title: 'Escrever 1 página', impactTag: 'SANIDADE', xpValue: 10),
        ],
      ),
      _buildHabit(
        id: 'leitura_foco',
        title: 'Deep Read',
        category: 'MENTAL',
        duration: 'CONTÍNUO',
        imageUrl: 'assets/images/leitura.png',
        desc: 'Foco imersivo em literatura técnica ou ficção.',
        study: 'A leitura profunda reduz o estresse em até 68%.',
        fit: 90,
        benefits: [
          HabitBenefit(label: 'Inteligência', bonusValue: 20, iconType: 'menu_book'),
          HabitBenefit(label: 'Foco', bonusValue: 15, iconType: 'psychology'),
        ],
        tasks: [
          Task(title: 'Ler 20 páginas', impactTag: 'INTELIGÊNCIA', xpValue: 15),
        ],
      ),
      _buildHabit(
        id: 'hidratacao_otimizada',
        title: 'Hidratação',
        category: 'SAÚDE',
        duration: 'CONTÍNUO',
        imageUrl: 'assets/images/agua.png',
        desc: 'Manutenção da homeostase e performance cognitiva.',
        study: 'A desidratação leve de 2% prejudica tarefas cognitivas.',
        fit: 99,
        benefits: [
          HabitBenefit(label: 'Saúde', bonusValue: 15, iconType: 'water_drop'),
          HabitBenefit(label: 'Energia', bonusValue: 20, iconType: 'bolt'),
        ],
        tasks: [
          Task(title: 'Beber 2L de agua', impactTag: 'SAÚDE', xpValue: 20),
        ],
      ),
    ];
  }

  static Habit _buildHabit({
    required String id, 
    required String title, 
    required String category, 
    required String duration, 
    required String imageUrl, 
    required String desc,
    required String study, 
    required int fit, 
    required List<HabitBenefit> benefits,
    List<Task>? tasks,
  }) {
    return Habit(
      id: id,
      title: title,
      category: category,
      duration: duration,
      imageUrl: imageUrl,
      goalDescription: desc,
      scientificStudy: study,
      fitPercentage: fit,
      benefits: benefits,
      tasks: tasks ?? [],
    );
  }
}