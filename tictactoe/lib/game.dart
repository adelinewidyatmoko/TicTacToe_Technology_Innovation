import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tictactoe/home_page.dart';

class GamePage extends StatefulWidget {
  final int gridLength;
  final List<String> playerStrings;
  final int? maxPieces;
  final int playingAs = 0;
  const GamePage({
    super.key,
    required this.gridLength,
    required this.playerStrings,
    this.maxPieces,
  });

  @override
  State<GamePage> createState() =>
      // ignore: no_logic_in_create_state
      _GamePageState(gridLength, playerStrings, playingAs, maxPieces);
}

class _GamePageState extends State<GamePage> {
  int squareLength;
  List<String> playerStrings = [];

  late final int maxPieces;
  late final int gridSize;
  late final int playingAs;
  late var boxStates = List<int>.generate(gridSize, (i) => -1);
  late var gridCellKeys = List.generate(
    gridSize,
    (_) => GlobalKey<_GameCellState>(),
  );
  int turn = 0;

  _GamePageState(
    this.squareLength,
    this.playerStrings,
    this.playingAs,
    int? maxPieces,
  ) {
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
      appBar: AppBar(
        title: const Text("Tic Tac Toe"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      itemCount: gridSize,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: squareLength,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            _update(index, false);
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
                  Center(
                    child: Text(
                      !ended
                          ? turn == playingAs
                                ? "Your turn"
                                : "Waiting..."
                          : "",
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(bottomText, style: TextStyle(fontSize: 35)),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Return'),
              ),
            ),
          ],
        ),
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

  void botTurn() async {
    var rng = Random();
    await Future.delayed(Duration(milliseconds: (500 + rng.nextInt(1000))));
    _update(basicAI(), true);
  }

  int basicAI() {
    var rng = Random();

    int steps = rng.nextInt(gridSize - activeIndeces.length);

    if (steps == -1) {
      return -1;
    }

    int currentPosition = 0;

    print("------ $steps");
    while (true) {
      print("$steps  $currentPosition ${(steps == 0) ? "yes " : "no "}");
      if (steps == 0 && !activeIndeces.contains(currentPosition)) {
        return currentPosition;
      } else if (!activeIndeces.contains(currentPosition)) {
        steps--;
      }
      currentPosition++;
    }
  }

  void _update(int index, bool botOverride) {
    if ((activeIndeces.contains(index) || turn != playingAs || ended) &&
        !botOverride) {
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

        bottomText = winCheck.winningPlayer == playingAs
            ? "You Win!"
            : "You Lost!";
      }

      // bot's turn
      if (turn != playingAs && !ended) {
        botTurn();
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
  int flash = 0;
  final rng = Random();
  double dx = 0, dy = 0;

  Color backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(t),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        var triangle = 1 - (2 * value - 1).abs();

        final animatedColor = Color.lerp(
          backgroundColor,
          Colors.red,
          triangle * flash,
        );

        return Transform.translate(
          offset: Offset(
            triangle * 40 * dx * (triangle > 0.5 ? -1 : 1),
            triangle * 40 * dy * (triangle > 0.5 ? -1 : 1),
          ),
          child: Container(color: animatedColor, child: child),
        );
      },
      child: widget.child,
    );
  }

  void _shake() {
    dx = rng.nextDouble() - 0.5;
    dy = rng.nextDouble() - 0.5;
    flash = 1;
    setState(() => t = t + 1);
  }

  void _makeGreen() {
    setState(() {
      backgroundColor = Colors.green;
    });
  }
}
