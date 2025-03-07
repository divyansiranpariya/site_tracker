import 'package:flutter/material.dart';
import 'package:interview/view/entry_page.dart';
import 'package:interview/view/homepage.dart';
import 'package:provider/provider.dart';

import 'model_view/MaterialProvider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => MaterialProvider())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomePage(),
        'Entry_screen': (context) => EntryScreen()
      },
    );
  }
}
