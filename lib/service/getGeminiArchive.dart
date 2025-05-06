import 'dart:io';
import 'dart:convert'; // Para codificação Base64
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> analyzeFileWithGoogleGenerativeAI(FilePickerResult file) async {
  try {
    // Carrega a chave da API do arquivo .env
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['API_KEY'];

    if (apiKey == null) {
      throw Exception('Chave de API não encontrada. Verifique o arquivo .env.');
    }

    // Inicializa o modelo generativo
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    // Lê o conteúdo do arquivo como bytes e codifica em Base64
    final fileBytes = await file.readAsBytes();
    final base64File = base64Encode(fileBytes);

    // Prompt inicial para o modelo
    const prePrompt =
        "Você é um assistente jurídico especializado em direito civil. Analise o conteúdo do arquivo fornecido e forneça um resumo claro e objetivo. Evite jargões e explique de forma acessível.";

    // Envia o arquivo codificado em Base64 para o modelo
    final content = [
      Content.text(prePrompt),
      Content.text("Arquivo codificado em Base64:\n$base64File"),
    ];
    final response = await model.generateContent(content);

    // Retorna a análise gerada
    if (response.text != null) {
      print('Análise do arquivo:');
      return response.text;
    } else {
      return 'Nenhuma resposta foi gerada pelo modelo.';
    }
  } catch (e) {
    return 'Erro ao analisar o arquivo: $e';
  }
}
