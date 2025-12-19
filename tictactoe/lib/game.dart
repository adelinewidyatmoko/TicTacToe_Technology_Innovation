import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tictactoe/utils/user_utils.dart';

class GamePage extends StatefulWidget {
  final int gridLength;
  final List<String> playerStrings;
  final int gameReward;
  final int? maxPieces;
  final int playingAs = 0;
  final bool? displayEarliestPiece;
  final bool? blind;
  final int? stepsPerTurn;
  const GamePage({
    super.key,
    required this.gridLength,
    required this.playerStrings,
    required this.gameReward,
    this.maxPieces,
    this.displayEarliestPiece,
    this.blind,
    this.stepsPerTurn,
  });

  @override
  State<GamePage> createState() =>
      // ignore: no_logic_in_create_state
      _GamePageState(
        gridLength,
        playerStrings,
        gameReward,
        playingAs,
        maxPieces,
        displayEarliestPiece,
        blind,
        stepsPerTurn,
      );
}

class _GamePageState extends State<GamePage> {
  final int squareLength;
  List<String> playerStrings = [];
  final int gameReward;

  late final int maxPieces;
  late final int gridSize;
  late final int playingAs;
  late var boxStates = List<int>.generate(gridSize, (i) => -1);
  late var gridCellKeys = List.generate(
    gridSize,
    (_) => GlobalKey<_GameCellState>(),
  );

  int turn = 0;
  bool ended = false;
  List<int> activeIndeces = [];
  String bottomText = "";
  bool displayEarliestPiece = false;
  bool blind = false;
  int stepsPerTurn = 1;
  int _currentStep = 0;

  _GamePageState(
    this.squareLength,
    this.playerStrings,
    this.gameReward,
    this.playingAs,
    int? maxPieces,
    bool? displayEarliestPiece,
    bool? blind,
    int? stepsPerTurn,
  ) {
    gridSize = squareLength * squareLength;
    this.maxPieces = min(
      max(0, (maxPieces ?? (gridSize - squareLength))),
      gridSize,
    );

    if (displayEarliestPiece != null) {
      this.displayEarliestPiece = displayEarliestPiece;
    }

    if (blind != null) {
      this.blind = blind;
    }

    if (stepsPerTurn != null) {
      this.stepsPerTurn = stepsPerTurn;
    }
  }
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
                      "Pieces left: ${piecesLeft()}",
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
                                        : (blind & !ended
                                              ? "#"
                                              : playerStrings[boxStates[index]]),
                                    style: TextStyle(
                                      fontSize: 100,
                                      color:
                                          !displayEarliestPiece &&
                                              activeIndeces.isNotEmpty &&
                                              activeIndeces[0] == index &&
                                              piecesLeft() <= 0
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
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

  void _update(int index, bool botOverride) {
    if ((activeIndeces.contains(index) || turn != playingAs || ended) &&
        !botOverride) {
      gridCellKeys[index].currentState?._shake();
      return;
    }

    setState(() {
      boxStates[index] = turn;
      _currentStep++;

      if (_currentStep >= stepsPerTurn) {
        turn++;
        _currentStep = 0;
      }
      turn %= playerStrings.length;

      if (piecesLeft() <= 0) {
        boxStates[activeIndeces.removeAt(0)] = -1;
      }
      activeIndeces.add(index);

      var winnerRecord = _checkWinner();

      if (winnerRecord.winningPlayer != -1) {
        _endGame();
        calculateWin(winnerRecord);
      }

      // bot's turn
      if (turn != playingAs && !ended) {
        botTurn();
      }
    });
  }

  void calculateWin(WinnerRecord winnerRecord) {
    for (int i = 0; i < winnerRecord.winningTiles.length; i++) {
      gridCellKeys[winnerRecord.winningTiles[i]].currentState?._makeGreen();
    }

    // check if the player has won
    if (winnerRecord.winningPlayer == playingAs) {
      var userEmail = getCurrentUserEmail();

      if (userEmail != null) {
        incrementUserScore(userEmail, gameReward);
      }

      bottomText = "You Win!";
    } else {
      bottomText = "You Lost!";
    }
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
    int currentPosition = 0;

    while (true) {
      if (steps == 0 && !activeIndeces.contains(currentPosition)) {
        return currentPosition;
      } else if (!activeIndeces.contains(currentPosition)) {
        steps--;
      }
      currentPosition++;
    }
  }

  int piecesLeft() {
    return maxPieces - activeIndeces.length;
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
            triangle * 40 * dx * triangle,
            triangle * 40 * dy * triangle,
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
