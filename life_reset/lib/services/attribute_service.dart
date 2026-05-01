import '../models/task.dart';
import '../models/attribute_stats.dart';
import '../services/storage_service.dart';

class AttributeService {
  static Future<void> applyTaskReward(Task task, {required bool isAdding}) async {
    AttributeStats stats = await StorageService.loadAttributeStats();
    
    // Pega o valor real de XP da tarefa configurada no catálogo
    double amount = task.xpValue; 
    
    if (!isAdding) amount = -amount;

    String tag = task.impactTag.toUpperCase().trim();

    // Mapeamento à prova de falhas para evolução de status
    switch (tag) {
      case 'FISICO':
      case 'FÍSICO':
        stats.physique = (stats.physique + amount).clamp(0.0, double.infinity);
        break;

      case 'SAÚDE':
      case 'SAUDE':
        stats.health = (stats.health + amount).clamp(0.0, double.infinity);
        break;

      case 'INTELIGENCIA':
      case 'INTELIGÊNCIA':
        stats.intellect = (stats.intellect + amount).clamp(0.0, double.infinity);
        break;

      case 'SANIDADE':
        stats.sanity = (stats.sanity + amount).clamp(0.0, double.infinity);
        break;

      case 'APARÊNCIA':
      case 'APARENCIA':
        stats.appearance = (stats.appearance + amount).clamp(0.0, double.infinity);
        break;

      case 'AUTOESTIMA':
        stats.selfEsteem = (stats.selfEsteem + amount).clamp(0.0, double.infinity);
        break;

      case 'CARREIRA':
        stats.career = (stats.career + amount).clamp(0.0, double.infinity);
        break;

      case 'SOCIAL':
        stats.social = (stats.social + amount).clamp(0.0, double.infinity);
        break;

      case 'ESTAMINA':
      case 'STAMINA':
        stats.stamina = (stats.stamina + amount).clamp(0.0, double.infinity);
        break;

      default:
        // Caso a tag seja genérica ou não encontrada, evolui Stamina por padrão
        stats.stamina = (stats.stamina + amount).clamp(0.0, double.infinity);
        break;
    }

    // Salva os status atualizados no Storage
    await StorageService.saveAttributeStats(stats);
  }
}