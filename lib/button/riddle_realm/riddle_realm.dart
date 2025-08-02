import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:math';

class RiddleRealmScreen extends StatefulWidget {
  const RiddleRealmScreen({Key? key}) : super(key: key);

  @override
  _RiddleRealmScreenState createState() => _RiddleRealmScreenState();
}

class _RiddleRealmScreenState extends State<RiddleRealmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _answerController = TextEditingController();
  final List<String> _riddles = const [
    "I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?",
    "What has an eye, but cannot see?",
    "What is full of holes but still holds water?",
    "What question can you never answer yes to?",
    "What is always in front of you but can’t be seen?",
    "I am always hungry, I must always be fed, The finger I touch, Will soon turn red. What am I?",
    "What has cities, but no houses; forests, but no trees; and water, but no fish?",
    "The more you take, the more you leave behind. What am I?",
    "What has to be broken before you can use it?",
    "I have branches, but no fruit, trunk, or leaves. What am I?",
    "What is so fragile that saying its name breaks it?",
    "What goes up but never comes down?",
    "What is always coming, but never arrives?",
    "What gets wet while drying?",
    "What has a neck but no head?",
    "What has a thumb and four fingers, but is not alive?",
    "What kind of room has no doors or windows?",
    "What is always in front of you but can’t be seen?",
    "I am an endless loop, a futile quest, a promise never kept. What am I?",
  ];
  String _currentRiddle = "";
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryAnimationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entryAnimationController.forward();
    _setNewRiddle();
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _setNewRiddle() {
    setState(() {
      _currentRiddle = _riddles[_random.nextInt(_riddles.length)];
      _answerController.clear();
    });
  }

  void _handleSubmitAnswer() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: 'Incorrect!',
      desc: 'That\'s not the answer. Try another riddle!',
      btnOkOnPress: () {
        _setNewRiddle();
      },
      btnOkColor: Colors.red,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void _showGiveUpDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      title: 'Heheheee ',
      desc: 'Are u such a wuss to leave it like that',
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade700,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close Riddle Realm',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The Infinite Riddle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _currentRiddle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      labelText: 'Your Answer',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                      ),
                      filled: true,
                      fillColor: Colors.deepPurple.shade600,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white70,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) =>
                        _handleSubmitAnswer(),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _handleSubmitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Submit Answer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _showGiveUpDialog,
                    child: Text(
                      'Give Up?',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
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