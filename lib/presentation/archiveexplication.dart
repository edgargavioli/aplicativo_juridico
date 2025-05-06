import 'package:assistente_juridico/service/getGeminiArchive.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ArchiveExplicationScreen extends StatefulWidget {
  @override
  _ArchiveExplicationScreenState createState() =>
      _ArchiveExplicationScreenState();
}

class _ArchiveExplicationScreenState extends State<ArchiveExplicationScreen> {
  File? _selectedFile;
  Future<FilePickerResult?>? _filePickerResult;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });

      setState(() {
        _filePickerResult = FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ['pdf', 'docx', 'txt'],
        );
      });
    }
  }

  Future<void> _sendFile() async {
    if (_selectedFile != null) {
      final response = await analyzeFileWithGoogleGenerativeAI(
        _filePickerResult!,
      );
      if (response != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Text(
                          'Explicação do Arquivo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(response, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                        Text(response, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao processar o arquivo.')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nenhum arquivo selecionado')));
    }
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
                    'Assistente Jurídico',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedFile != null
                    ? 'Arquivo: ${_selectedFile!.path}'
                    : 'Nenhum arquivo selecionado',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text('Selecionar Arquivo'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendFile,
                child: Text('Enviar Arquivo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
