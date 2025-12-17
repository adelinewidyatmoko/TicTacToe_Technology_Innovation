import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: GamePage());
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var boxStates = List<int>.generate(9, (i) => 0);
  var gridCellKeys = List.generate(9, (_) => GlobalKey<_ShakingCellState>());
  int turn = 0;

  List<int> activeIndeces = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GridView.builder(
        itemCount: 9,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              if (activeIndeces.contains(index)) {
                gridCellKeys[index].currentState?._shake();
                return;
              }

              _update(index);
            },
            child: ShakingCell(
              key: gridCellKeys[index],
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    boxStates[index] == 0
                        ? ""
                        : boxStates[index] == 1
                        ? "O"
                        : "X",
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _update(int index) {
    setState(() {
      if (turn == 0) {
        boxStates[index] = 1;
        turn = 1;
      } else if (turn == 1) {
        boxStates[index] = 2;
        turn = 0;
      }

      if (activeIndeces.length >= 6) {
        boxStates[activeIndeces.removeAt(0)] = 0;
      }
      activeIndeces.add(index);
      print(activeIndeces);
    });
  }
}

class ShakingCell extends StatefulWidget {
  final Widget child;

  const ShakingCell({super.key, required this.child});

  @override
  State<ShakingCell> createState() => _ShakingCellState();
}

class _ShakingCellState extends State<ShakingCell> {
  int t = 0;
  final rng = Random();
  double dx = 0, dy = 0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(t),
      tween: Tween(begin: 1, end: 0),
      duration: Duration(milliseconds: 300),
      builder: (context, value, child) {
        print(value);
        return Transform.translate(
          offset: Offset(
            value * 40 * dx * (value > 0.5 ? -1 : 1),
            value * 40 * dy * (value > 0.5 ? -1 : 1),
          ),
          child: child,
        );
      },

      child: widget.child,
    );
  }

  void _shake() {
    dx = rng.nextDouble() - 0.5;
    dy = rng.nextDouble() - 0.5;
    setState(() => t = t + 1);
  }
}
