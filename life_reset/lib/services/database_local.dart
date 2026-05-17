import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class DatabaseLocal {
  // Pega o diretório de documentos do app (permanente, separado do cache)
  Future<String> get _caminhoLocal async {
    final diretorio = await getApplicationDocumentsDirectory();
    return diretorio.path;
  }

  // Cria a referência para o seu arquivo
  Future<File> get _arquivoLocal async {
    final caminho = await _caminhoLocal;
    return File('$caminho/banco_dados.json');
  }

  // Função para salvar os dados (substitui o conteúdo antigo pelo novo)
  Future<File> salvarDados(Map<String, dynamic> dados) async {
    final arquivo = await _arquivoLocal;
    // Converte as informações para texto em formato JSON
    String textoJson = jsonEncode(dados);
    return arquivo.writeAsString(textoJson);
  }

  // Função para ler os dados quando o app abrir
  Future<Map<String, dynamic>> lerDados() async {
    try {
      final arquivo = await _arquivoLocal;
      
      // Se for a primeira vez abrindo o app, o arquivo não existe
      if (!await arquivo.exists()) {
        return {};
      }

      // Lê o conteúdo do arquivo
      String conteudo = await arquivo.readAsString();
      return jsonDecode(conteudo);
    } catch (e) {
      // Retorna vazio caso dê erro na leitura, evitando que o app quebre
      return {}; 
    }
  }
}