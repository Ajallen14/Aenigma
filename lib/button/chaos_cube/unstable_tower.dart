import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; 
import 'dart:math' as math; 
import 'dart:async'; 

class GameCube {
  double x, y; 
  double dx, dy; 
  Color color;
  bool isStacked; 
  bool isCorrupted;
  GameCube({
    required this.x,
    required this.y,
    this.dx = 0.0,
    this.dy = 0.0,
    required this.color,
    this.isStacked = false,
    this.isCorrupted = false,
  });
}

class UnstableTowerGameScreen extends StatefulWidget {
  const UnstableTowerGameScreen({super.key});

  @override
  _UnstableTowerGameScreenState createState() =>
      _UnstableTowerGameScreenState();
}

class _UnstableTowerGameScreenState extends State<UnstableTowerGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final math.Random _random = math.Random();
  final double _cubeSize = 50.0; 
  final double _gravity = 0.5; 
  final double _friction = 0.9; 
  final double _bounceFactor = 0.3; 
  final List<GameCube> _cubes = [];
  Timer? _gameLoopTimer;
  Timer? _spawnCubeTimer;
  Timer? _chaosEventTimer;

  double _groundY = 0.0;
  int _timeSurvived = 0;
  int _collapseCount = 0;
  bool _isGameRunning = false;

  final List<Color> _availableColors = [
    Colors.red.shade400,
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.yellow.shade400,
    Colors.purple.shade400,
    Colors.orange.shade400,
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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entryAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isGameRunning) {
        _resetGame();
      }
    });
  }

  Color _getRandomColor() {
    return _availableColors[_random.nextInt(_availableColors.length)];
  }

  void _resetGame() {
    if (!mounted) return;
    setState(() {
      _cubes.clear();
      _timeSurvived = 0;
      _collapseCount = 0;
      _isGameRunning = true;
      _gameLoopTimer?.cancel();
      _spawnCubeTimer?.cancel();
      _chaosEventTimer?.cancel();

      _gameLoopTimer = Timer.periodic(
        const Duration(milliseconds: 16),
        _updateGame,
      );
      _spawnCubeTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _spawnCube(),
      );
      _chaosEventTimer = Timer.periodic(
        const Duration(seconds: 7),
        (_) => _triggerChaosEvent(),
      );

      _spawnCube();
      _spawnCube();
    });
  }

  void _updateGame(Timer timer) {
    if (!_isGameRunning || !mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      _timeSurvived++;

      for (int i = 0; i < _cubes.length; i++) {
        final cube = _cubes[i];

        if (!cube.isStacked) {
          cube.dy += _gravity;

          if (_random.nextDouble() < 0.05) {
            cube.dx +=
                (_random.nextBool() ? 0.5 : -0.5) * (_random.nextDouble() * 2);
          }

          cube.dx *= _friction;

          cube.x += cube.dx;
          cube.y += cube.dy;

          if (cube.x < 0) {
            cube.x = 0;
            cube.dx = -cube.dx * _bounceFactor;
          } else if (cube.x + _cubeSize > screenWidth) {
            cube.x = screenWidth - _cubeSize;
            cube.dx = -cube.dx * _bounceFactor;
          }

          if (cube.y + _cubeSize >= _groundY) {
            cube.y = _groundY - _cubeSize;
            cube.dy = 0;
            cube.isStacked = true;
            cube.dx = 0; 
          }
        }

        for (int j = 0; j < _cubes.length; j++) {
          if (i == j) continue; 

          final otherCube = _cubes[j];

          if (!cube.isStacked &&
              otherCube.isStacked &&
              cube.y + _cubeSize >= otherCube.y &&
              cube.y < otherCube.y + _cubeSize &&
              cube.x < otherCube.x + _cubeSize &&
              cube.x + _cubeSize > otherCube.x) {
            if (cube.dy > 0) {
              cube.y = otherCube.y - _cubeSize;
              cube.dy = 0;
              cube.isStacked = true;
              cube.dx = 0;
            }
          }
        }
      }

      bool anyCollapsed = _cubes.any((cube) => cube.y + _cubeSize > _groundY + 50);

      if (anyCollapsed && _cubes.isNotEmpty) {
        _collapseCount++;
        _isGameRunning = false; 
        _gameLoopTimer?.cancel();
        _spawnCubeTimer?.cancel();
        _chaosEventTimer?.cancel();
        _showCollapseDialog();
      }
    });
  }

  void _spawnCube() {
    if (!_isGameRunning || !mounted) return;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isCorrupted =
        _random.nextDouble() < 0.2; 
    _cubes.add(
      GameCube(
        x:
            _random.nextDouble() *
            (screenWidth - _cubeSize),
        y: -_cubeSize, 
        color: isCorrupted
            ? Colors.red.shade900
            : _getRandomColor(), 
        dx: isCorrupted
            ? (_random.nextBool() ? 2.0 : -2.0)
            : 0.0,
        isCorrupted: isCorrupted,
      ),
    );
  }

  void _triggerChaosEvent() {
    if (!_isGameRunning || !mounted) return;

    final int eventType = _random.nextInt(3);

    if (eventType == 0) {
      final double windForce = (_random.nextBool() ? 5.0 : -5.0);
      for (final cube in _cubes) {
          cube.dx += windForce;
          if(cube.isStacked) cube.isStacked = false; 
      }
      _showTemporaryMessage('Wind Gust! 🌬️');
    } else if (eventType == 1) {
      for (final cube in _cubes) {
        if (cube.isStacked) {
          cube.isStacked = false; 
          cube.dy -= _random.nextDouble() * 10 + 5; 
          cube.dx +=
              (_random.nextBool() ? 1.0 : -1.0) *
              (_random.nextDouble() * 3);
        }
      }
      _showTemporaryMessage('Ground Tremor! 🌋');
    } else if (eventType == 2 && _cubes.isNotEmpty) {
      final int targetIndex = _random.nextInt(_cubes.length);
      final cube = _cubes[targetIndex];
      if (!cube.isCorrupted) {
        setState(() {
          cube.color = Colors.black; 
          cube.isCorrupted = true;
          cube.dx += (_random.nextBool() ? 5.0 : -5.0); 
          if(cube.isStacked) cube.isStacked = false;
        });
        _showTemporaryMessage('Cube Corrupted! 💀');
      }
    }
  }

  void _showTemporaryMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.amber.shade700,
      ),
    );
  }

  void _showCollapseDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: 'Tower Collapsed!',
      desc:
          'Order is an illusion. Chaos reigns eternal. You are bound to the collapse.',
      btnOkOnPress: () {
        _resetGame(); 
      },
      btnOkColor: Colors.red,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void _showEscapeDialog() {
    _isGameRunning = false;
    _gameLoopTimer?.cancel();
    _spawnCubeTimer?.cancel();
    _chaosEventTimer?.cancel();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      title: 'Order is an Illusion',
      desc: 'Chaos reigns eternal. You are bound to the collapse.',
      btnOkOnPress: () {}, 
      btnOkColor: Colors.purple,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _gameLoopTimer?.cancel();
    _spawnCubeTimer?.cancel();
    _chaosEventTimer?.cancel();
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
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close Game',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The Unstable Tower',
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
                  'Time Survived: ${(_timeSurvived / 60).floor()}s | Collapses: $_collapseCount',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _groundY =
                          constraints.maxHeight -
                          20;
                      return Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 20,
                            child: Container(color: Colors.brown.shade700),
                          ),
                          ..._cubes.map((cube) {
                            return Positioned(
                              left: cube.x,
                              top: cube.y,
                              width: _cubeSize,
                              height: _cubeSize,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cube.color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.5),
                                    width: cube.isCorrupted ? 3 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
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
