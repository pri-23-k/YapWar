import 'package:flutter/material.dart';
import 'package:yap/backend/api/Everyone.api.dart';
import 'package:yap/pages/intro_page.dart';

Future<void> main() async {
  print("called");
  runApp(const MyApp());
  await Everyone.factCheck("I am him");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAnimatedBackground(),
    );
  }
}
