import 'package:assistente_juridico/service/getGeminiMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<types.Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final types.User _user = types.User(id: 'user');
  final types.User _bot = types.User(id: 'bot');
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _initTts() {
    _flutterTts.setLanguage("pt-BR");
    _flutterTts.setSpeechRate(1.5);
    _flutterTts.setPitch(1.0);
  }

  void _readMessage(String text) async {
    setState(() {
      _isSpeaking = true;
    });

    await _flutterTts.speak(text);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  void _stopTts() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  void _startListening() async {
    if (!_speech.isListening) {
      await _speech.listen(onResult: _onSpeechResult, localeId: 'pt-BR');
      setState(() {});
    } else {
      print("O reconhecimento de fala já está ativo.");
    }
  }

  void _stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      setState(() {
        _controller.text = _text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    } else {
      print("O reconhecimento de fala já está parado.");
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
    });
  }

  void _sendMessage(String text) async {
    setState(() {
      _messages.add(
        types.TextMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          text: text,
        ),
      );
    });

    String? botResponse = await getGeminiResponse(text, context);

    setState(() {
      _messages.add(
        types.TextMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          text: botResponse ?? 'Erro ao obter resposta',
        ),
      );
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Assistente Jurídico"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              theme: DefaultChatTheme(
                backgroundColor: Theme.of(context).colorScheme.surface,
                userAvatarNameColors: [Colors.blue, Colors.green],
                sentMessageBodyTextStyle: TextStyle(color: Colors.white),
                primaryColor: Theme.of(context).colorScheme.secondaryContainer,
                receivedMessageBodyTextStyle: TextStyle(color: Colors.white),
                secondaryColor: Theme.of(context).colorScheme.tertiaryContainer,
              ),
              emptyState: Center(
                child: Text(
                  'Converse com seu assistente jurídico',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ),
              messages: _messages.reversed.toList(),
              onMessageTap: (context, message) {
                if (message is types.TextMessage) {
                  _readMessage(message.text);
                }
              },
              onSendPressed: (message) => {_sendMessage(message.text)},
              user: _user,
              inputOptions: InputOptions(
                textEditingController: _controller,
                sendButtonVisibilityMode: SendButtonVisibilityMode.always,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child:
            _isSpeaking
                ? FloatingActionButton(
                  onPressed: _stopTts,
                  tooltip: 'Parar fala',
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.stop),
                )
                : FloatingActionButton(
                  onPressed:
                      _speech.isNotListening ? _startListening : _stopListening,
                  tooltip: 'Pressione para falar',
                  child: Icon(
                    _speech.isNotListening ? Icons.mic_off : Icons.mic,
                  ),
                ),
      ),
    );
  }
}
