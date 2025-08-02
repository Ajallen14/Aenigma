import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:math' as math;

class ParadoxicalSequenceGameScreen extends StatefulWidget {
  const ParadoxicalSequenceGameScreen({Key? key}) : super(key: key);

  @override
  _ParadoxicalSequenceGameScreenState createState() => _ParadoxicalSequenceGameScreenState();
}

class _ParadoxicalSequenceGameScreenState extends State<ParadoxicalSequenceGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _answerController = TextEditingController();
  final math.Random _random = math.Random();

  List<int> _currentSequence = [];
  int _nextExpectedItem = 0;
  String _currentRuleType = '';

  final List<String Function(int, int)> _ruleGenerators = [
    (start, factor) {
      return 'add_${factor}';
    },
    (start, factor) {
      return 'multiply_by_${factor}';
    },
    (start, factor) {
      return 'subtract_${factor}';
    },
    (start, factor) {
      return 'alternate_add_subtract_${factor}';
    },
    (start, factor) {
      return 'fibonacci_like';
    },
  ];

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryAnimationController, curve: Curves.easeOutCubic),
    );

    _entryAnimationController.forward();

    _generateNewSequence();
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _generateNewSequence() {
    setState(() {
      _currentSequence.clear();
      _answerController.clear();

      final int ruleIndex = _random.nextInt(_ruleGenerators.length);
      final int startValue = _random.nextInt(10) + 1;
      final int factor = _random.nextInt(5) + 1;

      _currentRuleType = _ruleGenerators[ruleIndex](startValue, factor);

      _currentSequence.add(startValue);
      for (int i = 0; i < 3; i++) {
        int nextVal;
        if (_currentRuleType.startsWith('add_')) {
          nextVal = _currentSequence.last + factor;
        } else if (_currentRuleType.startsWith('multiply_by_')) {
          nextVal = _currentSequence.last * factor;
        } else if (_currentRuleType.startsWith('subtract_')) {
          nextVal = _currentSequence.last - factor;
        } else if (_currentRuleType.startsWith('alternate_add_subtract_')) {
          if (i % 2 == 0) {
            nextVal = _currentSequence.last + factor;
          } else {
            nextVal = _currentSequence.last - factor;
          }
        } else if (_currentRuleType == 'fibonacci_like') {
          if (_currentSequence.length < 2) {
            nextVal = _random.nextInt(10) + 1;
          } else {
            nextVal = _currentSequence[_currentSequence.length - 1] + _currentSequence[_currentSequence.length - 2];
          }
        } else {
          nextVal = _currentSequence.last + 1;
        }
        _currentSequence.add(nextVal);
      }

      if (_currentRuleType.startsWith('add_')) {
        _nextExpectedItem = _currentSequence.last + factor;
      } else if (_currentRuleType.startsWith('multiply_by_')) {
        _nextExpectedItem = _currentSequence.last * factor;
      } else if (_currentRuleType.startsWith('subtract_')) {
        _nextExpectedItem = _currentSequence.last - factor;
      } else if (_currentRuleType.startsWith('alternate_add_subtract_')) {
        if (_currentSequence.length % 2 == 0) {
          _nextExpectedItem = _currentSequence.last - factor;
        } else {
          _nextExpectedItem = _currentSequence.last + factor;
        }
      } else if (_currentRuleType == 'fibonacci_like') {
        _nextExpectedItem = _currentSequence[_currentSequence.length - 1] + _currentSequence[_currentSequence.length - 2];
      } else {
        _nextExpectedItem = _currentSequence.last + 1;
      }

      if (_random.nextDouble() < 0.3) {
        _nextExpectedItem += (_random.nextBool() ? 1 : -1) * (_random.nextInt(2) + 1);
      }
    });
  }

  void _handleSubmitAnswer() {
    final int? userAnswer = int.tryParse(_answerController.text);

    String title;
    String desc;
    DialogType type;
    Color btnColor;

    if (userAnswer == _nextExpectedItem) {
      title = 'Intriguing...';
      desc = 'A logical step, but the pattern evolves. Here\'s a new one!';
      type = DialogType.info;
      btnColor = Colors.green;
    } else {
      title = 'Logical Misstep!';
      desc = 'The labyrinth shifts. A new challenge awaits!';
      type = DialogType.error;
      btnColor = Colors.red;
    }

    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: title,
      desc: desc,
      btnOkOnPress: () {
        _generateNewSequence();
      },
      btnOkColor: btnColor,
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
      title: 'Your Logic Cannot Unravel This',
      desc: 'The labyrinth holds you. There is no escape.',
      btnOkOnPress: () {},
      btnOkColor: Colors.purple,
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
                  color: Colors.black.withOpacity(0.4),
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
                      icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close Game',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The Paradoxical Sequence',
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
                    'What comes next in this sequence?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade600,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Text(
                      _currentSequence.join(', '),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your Guess',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                      filled: true,
                      fillColor: Colors.deepPurple.shade600,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lightbulb_outline, color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (value) => _handleSubmitAnswer(),
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
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Submit Guess',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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