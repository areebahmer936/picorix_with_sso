import 'package:flutter/material.dart';

class WordSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WordSearchGame(),
    );
  }
}

class WordSearchGame extends StatefulWidget {
  @override
  _WordSearchGameState createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  List<List<String>> grid = [
    ['F', 'L', 'U', 'T', 'T', 'E', 'R'],
    ['W', 'O', 'R', 'D', 'S', 'E', 'A'],
    ['D', 'A', 'R', 'G', 'N', 'I', 'G'],
    ['E', 'X', 'A', 'M', 'P', 'L', 'E'],
  ];

  List<String> selectedWord = [];
  String currentWord = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Search Game'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid[0].length,
              ),
              itemBuilder: (BuildContext context, int index) {
                final letter =
                    grid[index ~/ grid[0].length][index % grid[0].length];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentWord = letter;
                      selectedWord = [letter];
                    });
                  },
                  onPanUpdate: (details) {
                    final letterIndex = index ~/ grid[0].length;
                    if (letterIndex < grid.length) {
                      final letter = grid[letterIndex][index % grid[0].length];
                      if (!selectedWord.contains(letter)) {
                        setState(() {
                          currentWord += letter;
                          selectedWord.add(letter);
                        });
                      }
                    }
                  },
                  onPanEnd: (details) {
                    if (isWordValid(selectedWord)) {
                      highlightWord();
                    }
                    setState(() {
                      currentWord = '';
                      selectedWord.clear();
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: selectedWord.contains(letter)
                          ? Colors.blue
                          : Colors.white,
                    ),
                    child: Text(letter),
                  ),
                );
              },
              itemCount: grid[0].length * grid.length,
            ),
          ],
        ),
      ),
    );
  }

  bool isWordValid(List<String> word) {
    // Implement word validation logic here, e.g., check against a word list.
    // For simplicity, this example does not include word validation.
    return true; // Replace with your validation logic.
  }

  void highlightWord() {
    // Implement highlighting logic here, e.g., change the style of the selected word.
    // For simplicity, this example does not include detailed highlighting.
  }
}
