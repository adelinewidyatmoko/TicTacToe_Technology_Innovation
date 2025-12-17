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
  var boxStates = List<int>.generate(9, (i) => -1);
  var gridCellKeys = List.generate(9, (_) => GlobalKey<_ShakingCellState>());
  int turn = 0;

  var playerStrings = ["O", "X"];

  List<int> activeIndeces = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "Turn: " + playerStrings[turn],
                style: TextStyle(fontSize: 35),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _update(index, boxStates);
                  },
                  child: ShakingCell(
                    key: gridCellKeys[index],
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          boxStates[index] == -1
                              ? ""
                              : playerStrings[boxStates[index]],
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _checkLine(
    int position,
    bool isRow,
    int lineLength,
    List<int> boxStates,
  ) {
    int currPosition = isRow ? position * lineLength : position;
    int player = -1;
    String debugCheck = "";

    print("Checking " + (isRow ? "row " : "column ") + position.toString());

    for (int i = 0; i < lineLength; i++) {
      int currentBoxPlayer = boxStates[currPosition];
      if (currentBoxPlayer == -1) {
        print(currPosition.toString() + " null");

        return -1;
      } else if (player == -1) {
        print(currPosition.toString() + " good");
        player = currentBoxPlayer;
      } else if (player != currentBoxPlayer) {
        print(
          currPosition.toString() +
              " clash " +
              player.toString() +
              "/" +
              currentBoxPlayer.toString(),
        );
        return -1;
      }

      currPosition += isRow ? 1 : lineLength;
    }
    return player;
  }

  int _checkDiagonal(bool positiveSlope, int lineLength, List<int> boxStates) {
    int currPosition = positiveSlope ? lineLength * lineLength - lineLength : 0;
    int player = -1;
    String debugCheck = "";

    print(
      "Checking " + (positiveSlope ? "positive " : "negative ") + "diagonal",
    );

    for (int i = 0; i < lineLength; i++) {
      int currentBoxPlayer = boxStates[currPosition];
      if (currentBoxPlayer == -1) {
        print(currPosition.toString() + " null");

        return -1;
      } else if (player == -1) {
        print(currPosition.toString() + " good");
        player = currentBoxPlayer;
      } else if (player != currentBoxPlayer) {
        print(
          currPosition.toString() +
              " clash " +
              player.toString() +
              "/" +
              currentBoxPlayer.toString(),
        );
        return -1;
      }

      currPosition += positiveSlope ? (-lineLength + 1) : (lineLength + 1);
    }

    return player;
  }

  void _update(int index, List<int> boxStates) {
    if (activeIndeces.contains(index)) {
      gridCellKeys[index].currentState?._shake();
      return;
    }

    setState(() {
      if (turn == 0) {
        boxStates[index] = 0;
        turn = 1;
      } else if (turn == 1) {
        boxStates[index] = 1;
        turn = 0;
      }

      if (activeIndeces.length >= 6) {
        boxStates[activeIndeces.removeAt(0)] = -1;
      }
      activeIndeces.add(index);

      int lineLength = 3;
      for (int i = 0; i < lineLength; i++) {
        int columnCheck = _checkLine(i, false, lineLength, boxStates);
        int rowCheck = _checkLine(i, true, lineLength, boxStates);

        if (columnCheck != -1) {
          print(
            "Winner: " + columnCheck.toString() + " on column " + i.toString(),
          );
          return;
        } else if (rowCheck != -1) {
          print("Winner: " + rowCheck.toString() + " on row " + i.toString());
          return;
        }
      }

      int negDiag = _checkDiagonal(false, lineLength, boxStates);
      int posDiag = _checkDiagonal(true, lineLength, boxStates);

      if (negDiag != -1) {
        print("Winner: " + negDiag.toString() + " on negative diagonal");
        return;
      } else if (posDiag != -1) {
        print("Winner: " + posDiag.toString() + " on positive diagonal");
        return;
      }
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
