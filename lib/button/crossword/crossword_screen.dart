import 'package:crossword/crossword.dart';
import 'package:flutter/material.dart';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({Key? key}) : super(key: key);

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  final List<List<String>> letters = const [
    ["F", "L", "U", "T", "T", "E", "R", "W", "U", "D", "B", "C"],
    ["R", "M", "I", "O", "P", "U", "I", "Q", "R", "L", "E", "G"],
    ["T", "V", "D", "I", "R", "I", "M", "U", "A", "H", "E", "A"],
    ["D", "A", "R", "T", "N", "S", "T", "O", "Y", "J", "R", "M"],
    ["O", "G", "A", "M", "E", "S", "C", "O", "L", "O", "R", "O"],
    ["S", "R", "T", "I", "I", "I", "F", "X", "S", "P", "E", "D"],
    ["Y", "S", "N", "E", "T", "M", "M", "C", "E", "A", "T", "S"],
    ["W", "E", "T", "P", "A", "T", "D", "Y", "L", "M", "N", "U"],
    ["O", "T", "E", "H", "R", "O", "G", "P", "T", "U", "O", "E"],
    ["K", "R", "R", "C", "G", "A", "M", "E", "S", "S", "T", "S"],
    ["S", "E", "S", "T", "L", "A", "O", "P", "U", "P", "E", "S"],
  ];

  final List<String> hints = const ["FLUTTER", "GAMES", "UI", "COLOR"];

  final GlobalKey<CrosswordState> crosswordState = GlobalKey<CrosswordState>();

  String word = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      appBar: AppBar(
        title: const Text(
          'The Unsolvable Crossword',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close Crossword',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                word.isEmpty ? 'Find a word!' : 'Selected: $word',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            Expanded(
              child: Crossword(
                key: crosswordState,
                letters: letters,
                hints: hints,
                textStyle: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                lineDecoration: const LineDecoration(
                  lineGradientColors: [
                    [
                      Colors.blue,
                      Colors.red,
                      Colors.orange,
                      Colors.amber,
                      Colors.green,
                    ],
                  ],
                  strokeWidth: 26,
                  lineTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                letterPopDecoration: const LetterPopDecoration(
                  onTouchPopScaleFactor: 1.5,
                  duration: Duration(milliseconds: 200),
                  onTouchLetterFontStyle: FontStyle.italic,
                ),
                revealLetterDecoration: const RevealLetterDecoration(
                  shakeOffset: Offset(10, 20),
                ),
                allowOverlap: false,
                spacing: const Offset(30, 30),
                onLineUpdate:
                    (String currentWord, List<String> foundWords, isLineDrawn) {
                      setState(() {
                        word = currentWord;
                      });
                      if (isLineDrawn) {
                        print('Word formed: $currentWord');
                        if (foundWords.contains(currentWord)) {
                          print('Found a hint word: $currentWord');
                        }
                      } else {
                      }
                    },
                addIncorrectWord:
                    false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Finished',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}