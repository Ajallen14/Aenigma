import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:math' as math;
import 'dart:async';

class ShiftingPatternGameScreen extends StatefulWidget {
  const ShiftingPatternGameScreen({super.key});

  @override
  _ShiftingPatternGameScreenState createState() => _ShiftingPatternGameScreenState();
}

class _ShiftingPatternGameScreenState extends State<ShiftingPatternGameScreen>
    with SingleTickerProviderStateMixin {
  final int _gridSize = 4; // 4x4 grid
  late List<List<Color>> _gridColors;
  late List<List<Color>> _targetPattern;
  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];
  final math.Random _random = math.Random();
  Timer? _targetShiftTimer;
  int _tapCount = 0;
  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _initializeGame();
    _startTargetShiftTimer();
  }

  void _initializeGame() {
    _gridColors = List.generate(
      _gridSize,
      (_) => List.generate(_gridSize, (_) => _getRandomColor()),
    );
    _targetPattern = List.generate(
      _gridSize,
      (_) => List.generate(_gridSize, (_) => _getRandomColor()),
    );
    _tapCount = 0;
  }

  Color _getRandomColor() {
    return _availableColors[_random.nextInt(_availableColors.length)];
  }

  void _startTargetShiftTimer() {
    _targetShiftTimer?.cancel();
    _targetShiftTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _shiftTargetPattern();
    });
  }

  void _shiftTargetPattern() {
    setState(() {
      final int changes = _random.nextInt(3) + 1; 
      for (int i = 0; i < changes; i++) {
        final int row = _random.nextInt(_gridSize);
        final int col = _random.nextInt(_gridSize);
        _targetPattern[row][col] = _getRandomColor();
      }
    });
  }

  void _handleTileTap(int row, int col) {
    setState(() {
      _tapCount++;
      _gridColors[row][col] = _getRandomColor();
      final int cascadeCount = _random.nextInt(5) + 1; 
      for (int i = 0; i < cascadeCount; i++) {
        final int r = _random.nextInt(_gridSize);
        final int c = _random.nextInt(_gridSize);
        _gridColors[r][c] = _getRandomColor();
      }
      if (_tapCount % 5 == 0) { 
        _shiftTargetPattern();
      }
    });
  }

  void _showEscapeDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      title: 'The Enigma is Eternal',
      desc: 'There is no escape. You are part of the pattern now.',
      btnOkOnPress: () {}, 
      btnOkColor: Colors.purple,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _targetShiftTimer?.cancel();
    super.dispose();
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
                  'The Shifting Pattern',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Match this pattern:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade600,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ _gridSize;
                      final col = index % _gridSize;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _targetPattern[row][col],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Pattern:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridSize,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _gridSize * _gridSize,
                      itemBuilder: (context, index) {
                        final row = index ~/ _gridSize;
                        final col = index % _gridSize;
                        return GestureDetector(
                          onTap: () => _handleTileTap(row, col),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: _gridColors[row][col],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showEscapeDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    elevation: 10,
                  ),
                  child: const Text(
                    'Escape?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
