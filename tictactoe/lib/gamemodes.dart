import 'package:flutter/material.dart';

import 'game.dart';

class Gamemodes extends StatelessWidget {
  const Gamemodes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Modes"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Expanded(
            flex: 12,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 3,
                            playerStrings: ["X", "O"],
                            gameReward: 100,
                            displayEarliestPiece: false,
                          ),
                        ),
                      );
                    },
                    child: const Text('Standard Mode'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 3,
                            playerStrings: ["X", "O"],
                            gameReward: 75,
                            displayEarliestPiece: true,
                          ),
                        ),
                      );
                    },
                    child: const Text('Easy Mode'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 3,
                            playerStrings: ["X", "O"],
                            gameReward: 150,
                            displayEarliestPiece: true,
                            blind: true,
                          ),
                        ),
                      );
                    },
                    child: const Text('Blind Mode'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 3,
                            playerStrings: ["X", "O"],
                            gameReward: 30,
                            stepsPerTurn: 2,
                          ),
                        ),
                      );
                    },
                    child: const Text('Blitz Mode'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 3,
                            playerStrings: ["X", "O"],
                            gameReward: 125,
                            stepsPerTurn: 2,
                            blind: true,
                          ),
                        ),
                      );
                    },
                    child: const Text('Blind Blitz'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 7,
                            playerStrings: ["X", "O"],
                            gameReward: 95,
                            stepsPerTurn: 2,
                          ),
                        ),
                      );
                    },
                    child: const Text('7x7 Blitz'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 7,
                            playerStrings: ["X", "O"],
                            displayEarliestPiece: true,
                            gameReward: 135,
                            blind: true,
                            stepsPerTurn: 2,
                          ),
                        ),
                      );
                    },
                    child: const Text('Blind 7x7 Blitz'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GamePage(
                            gridLength: 9,
                            playerStrings: ["X", "O"],
                            displayEarliestPiece: true,
                            gameReward: 155,
                            blind: true,
                            stepsPerTurn: 2,
                          ),
                        ),
                      );
                    },
                    child: const Text('Blind 9x9 Blitz'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
