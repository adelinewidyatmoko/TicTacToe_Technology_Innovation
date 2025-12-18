import 'dart:math';

import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final int gridLength;
  final List<String> playerStrings;
  final int? maxPieces;
  const GamePage({
    super.key,
    required this.gridLength,
    required this.playerStrings,
    this.maxPieces,
  });

  @override
  State<GamePage> createState() =>
      // ignore: no_logic_in_create_state
      _GamePageState(gridLength, playerStrings, maxPieces);
}

class _GamePageState extends State<GamePage> {
  int squareLength;
  List<String> playerStrings = [];

  late final int maxPieces;
  late final int gridSize;
  late var boxStates = List<int>.generate(gridSize, (i) => -1);
  late var gridCellKeys = List.generate(
    gridSize,
    (_) => GlobalKey<_GameCellState>(),
  );
  int turn = 0;

  _GamePageState(this.squareLength, this.playerStrings, int? maxPieces) {
    gridSize = squareLength * squareLength;
    this.maxPieces = min(
      max(0, (maxPieces ?? (gridSize - squareLength))),
      gridSize,
    );
  }

  bool ended = false;

  List<int> activeIndeces = [];

  String bottomText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Turn: ${playerStrings[turn]}",
                    style: TextStyle(fontSize: 35),
                  ),
                  Text(
                    "Pieces left: ${maxPieces - activeIndeces.length}",
                    style: TextStyle(fontSize: 35),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: GridView.builder(
              itemCount: gridSize,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: squareLength,
              ),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _update(index);
                  },
                  child: GameCell(
                    key: gridCellKeys[index],
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            boxStates[index] == -1
                                ? ""
                                : playerStrings[boxStates[index]],
                            style: TextStyle(fontSize: 100),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(bottomText, style: TextStyle(fontSize: 35)),
            ),
          ),
        ],
      ),
    );
  }

  WinnerRecord _checkLine(int position, bool isRow) {
    int currPosition = isRow ? position * squareLength : position;
    int player = -1;

    List<int> tiles = [];

    for (int i = 0; i < squareLength; i++) {
      int currentBoxPlayer = boxStates[currPosition];
      if (currentBoxPlayer == -1) {
        return WinnerRecord(-1, []);
      } else if (player == -1) {
        player = currentBoxPlayer;
      } else if (player != currentBoxPlayer) {
        return WinnerRecord(-1, []);
      }

      tiles.add(currPosition);
      currPosition += isRow ? 1 : squareLength;
    }
    return WinnerRecord(player, tiles);
  }

  WinnerRecord _checkDiagonal(bool positiveSlope) {
    int currPosition = positiveSlope
        ? squareLength * squareLength - squareLength
        : 0;
    int player = -1;

    List<int> tiles = [];

    for (int i = 0; i < squareLength; i++) {
      int currentBoxPlayer = boxStates[currPosition];
      if (currentBoxPlayer == -1) {
        return WinnerRecord(-1, []);
      } else if (player == -1) {
        player = currentBoxPlayer;
      } else if (player != currentBoxPlayer) {
        return WinnerRecord(-1, []);
      }

      tiles.add(currPosition);
      currPosition += positiveSlope ? (-squareLength + 1) : (squareLength + 1);
    }
    return WinnerRecord(player, tiles);
  }

  WinnerRecord _checkWinner() {
    for (int i = 0; i < squareLength; i++) {
      WinnerRecord columnCheck = _checkLine(i, false);
      WinnerRecord rowCheck = _checkLine(i, true);

      if (columnCheck.winningPlayer != -1) {
        return columnCheck;
      } else if (rowCheck.winningPlayer != -1) {
        return rowCheck;
      }
    }

    WinnerRecord negDiag = _checkDiagonal(false);
    WinnerRecord posDiag = _checkDiagonal(true);

    if (negDiag.winningPlayer != -1) {
      return negDiag;
    } else if (posDiag.winningPlayer != -1) {
      return posDiag;
    }

    return WinnerRecord(-1, []);
  }

  void _endGame() {
    ended = true;
  }

  void _update(int index) {
    if (activeIndeces.contains(index) || ended) {
      gridCellKeys[index].currentState?._shake();
      return;
    }

    setState(() {
      boxStates[index] = turn;
      turn++;
      turn %= playerStrings.length;

      if (activeIndeces.length >= maxPieces) {
        boxStates[activeIndeces.removeAt(0)] = -1;
      }
      activeIndeces.add(index);

      var winCheck = _checkWinner();

      if (winCheck.winningPlayer != -1) {
        _endGame();

        for (int i = 0; i < winCheck.winningTiles.length; i++) {
          gridCellKeys[winCheck.winningTiles[i]].currentState?._makeGreen();
        }

        bottomText = "Winner: ${playerStrings[winCheck.winningPlayer]}";
      }
    });
  }
}

class WinnerRecord {
  int winningPlayer = -1;
  List<int> winningTiles = [];

  WinnerRecord(this.winningPlayer, this.winningTiles);
}

class GameCell extends StatefulWidget {
  final Widget child;

  const GameCell({super.key, required this.child});

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> {
  int t = 0;
  final rng = Random();
  double dx = 0, dy = 0;

  Color backgroundColor = Colors.white;

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

      child: Container(color: backgroundColor, child: widget.child),
    );
  }

  void _shake() {
    dx = rng.nextDouble() - 0.5;
    dy = rng.nextDouble() - 0.5;
    setState(() => t = t + 1);
  }

  void _makeGreen() {
    setState(() {
      backgroundColor = Colors.green;
    });
  }
}
