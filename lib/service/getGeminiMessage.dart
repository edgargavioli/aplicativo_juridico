import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> getGeminiResponse(String userQuery, context) async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['API_KEY'];

  if (apiKey == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Erro ao se comunicar com a IA."),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        animation: CurvedAnimation(
          parent: AnimationController(
            duration: const Duration(milliseconds: 500),
            vsync: ScaffoldMessenger.of(context),
          ),
          curve: Curves.easeInOut,
        ),
        backgroundColor: Colors.red,
      ),
    );
    exit(1);
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  const prePrompt =
      "Você é um assistente jurídico especializado em direito civil. Responda de forma clara e objetiva. Ajude um leigo com os termos jurídicos e evite jargões. Não faça suposições sobre o que o usuário quer saber. Se não souber a resposta, diga que não sabe. Não forneça conselhos legais específicos. Pergunte se o usuário deseja mais informações ou ajuda com outro assunto.";
  final content = [Content.text("$prePrompt\n\n$userQuery")];

  final response = await model.generateContent(content);

  return response.text;
}
