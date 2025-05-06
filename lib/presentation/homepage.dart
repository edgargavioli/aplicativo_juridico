import 'package:assistente_juridico/service/getGeminiMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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

  void _sendMessage(String text) async {
    setState(() {
      _messages.add(
        types.TextMessage(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              (1000 + (1000 * (1 + _messages.length))).toString(),
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
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              (1000 + (1000 * (1 + _messages.length))).toString(),
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
        title: Builder(
          builder:
              (context) => Icon(
                Icons.menu_book,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assistente Juridico',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Escanear Documento'),
              onTap: () {
                Navigator.pushNamed(context, '/scan');
              },
            ),
          ],
        ),
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
              onSendPressed: (message) => {_sendMessage(message.text)},
              user: _user,
              inputOptions: InputOptions(textEditingController: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
