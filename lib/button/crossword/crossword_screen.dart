import 'package:crossword/crossword.dart';
import 'package:flutter/material.dart';

class CrosswordScreen extends StatefulWidget {
  const CrosswordScreen({Key? key}) : super(key: key);

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  final List<List<String>> letters = const [
    ['C', 'O', 'N', 'U', 'N', 'D', 'R', 'U', 'M', 'A', 'B', 'C'],
    ['X', 'L', 'Y', 'Z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
    ['P', 'A', 'R', 'A', 'D', 'O', 'X', 'I', 'J', 'K', 'L', 'M'],
    ['A', 'B', 'I', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'],
    ['R', 'Y', 'N', 'Z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'],
    ['A', 'R', 'T', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q'],
    ['D', 'I', 'H', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
    ['O', 'N', 'B', 'S', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q'],
    ['X', 'T', 'A', 'M', 'E', 'N', 'I', 'G', 'M', 'A', 'R', 'S'],
    ['W', 'V', 'L', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
    ['Q', 'R', 'S', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q'],
    ['H', 'S', 'I', 'R', 'E', 'B', 'B', 'I', 'G', 'X', 'Y', 'Z'],
  ];

  final List<String> hints = const [
    "PARADOX",
    "ENIGMA",
    "LABYRINTH",
    "CONUNDRUM",
    "MIASMA",
    "GIBBERISH",
  ];

  final GlobalKey<CrosswordState> crosswordState = GlobalKey<CrosswordState>();

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
                child: const Text('Finished'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
