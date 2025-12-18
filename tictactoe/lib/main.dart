import 'package:flutter/material.dart';
import 'package:tictactoe/game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(gridLength: 3, playerStrings: ["O", "X"]),
    );
  }
}
