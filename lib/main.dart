import 'package:assistente_juridico/presentation/homepage.dart';
import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(
      context,
      "Merriweather",
      "Playfair Display",
    );

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: 'Assistente Juridico',
      debugShowCheckedModeBanner: false,
      theme: theme.dark(),
      initialRoute: '/',
      routes: {'/': (context) => const HomePage()},
    );
  }
}
