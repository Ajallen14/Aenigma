import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:math' as math;
import 'dart:async';

class IllogicalPathGameScreen extends StatefulWidget {
  const IllogicalPathGameScreen({super.key});

  @override
  _IllogicalPathGameScreenState createState() =>
      _IllogicalPathGameScreenState();
}

class _IllogicalPathGameScreenState extends State<IllogicalPathGameScreen>
    with SingleTickerProviderStateMixin {
  final int _gridSize = 7; 
  late List<List<int>> _maze; 
  late int _playerRow, _playerCol;
  late int _endRow, _endCol;
  final math.Random _random = math.Random();
  Timer? _mazeShiftTimer;
  int _moveCount = 0;

  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, String> _controlMap = {};

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

    _initializeMaze();
    _updateControlMap();
    _startMazeShiftTimer();
  }

  void _initializeMaze() {
    setState(() {
      _maze = List.generate(
        _gridSize,
        (r) => List.generate(_gridSize, (c) => 0),
      );

      for (int i = 0; i < _gridSize * _gridSize / 5; i++) {
        _maze[_random.nextInt(_gridSize)][_random.nextInt(_gridSize)] = 1;
      }

      _playerRow = _random.nextInt(_gridSize);
      _playerCol = _random.nextInt(_gridSize);
      _maze[_playerRow][_playerCol] = 2; 

      do {
        _endRow = _random.nextInt(_gridSize);
        _endCol = _random.nextInt(_gridSize);
      } while ((_endRow == _playerRow && _endCol == _playerCol) ||
          _maze[_endRow][_endCol] == 1);
      _maze[_endRow][_endCol] = 3; 

      _moveCount = 0; 
    });
  }

  void _updateControlMap() {
    final List<String> actualDirections = ['Up', 'Down', 'Left', 'Right'];
    actualDirections.shuffle(_random);

    _controlMap = {
      'Up': actualDirections[0],
      'Down': actualDirections[1],
      'Left': actualDirections[2],
      'Right': actualDirections[3],
    };
  }

  void _startMazeShiftTimer() {
    _mazeShiftTimer?.cancel();
    _mazeShiftTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _shiftMazeLayout();
    });
  }

  void _shiftMazeLayout() {
    setState(() {
      final int changes = _random.nextInt(3) + 1;
      for (int i = 0; i < changes; i++) {
        final int r = _random.nextInt(_gridSize);
        final int c = _random.nextInt(_gridSize);

        if (!((r == _playerRow && c == _playerCol) ||
            (r == _endRow && c == _endCol))) {
          _maze[r][c] = 1 - _maze[r][c];
        }
      }
      _updateControlMap(); 
    });
  }

  void _movePlayer(String actualDirection) {
    if (_mazeShiftTimer != null && !_mazeShiftTimer!.isActive)
      return; 

    int newRow = _playerRow;
    int newCol = _playerCol;

    if (actualDirection == 'Up') {
      newRow--;
    } else if (actualDirection == 'Down') {
      newRow++;
    } else if (actualDirection == 'Left') {
      newCol--;
    } else if (actualDirection == 'Right') {
      newCol++;
    }

    if (newRow >= 0 &&
        newRow < _gridSize &&
        newCol >= 0 &&
        newCol < _gridSize &&
        _maze[newRow][newCol] != 1) {
      setState(() {
        _maze[_playerRow][_playerCol] = 0;
        _playerRow = newRow;
        _playerCol = newCol;
        _maze[_playerRow][_playerCol] = 2;
        _moveCount++;

        if (_playerRow == _endRow && _playerCol == _endCol) {
          _showNotQuiteDialog();
        }

        if (_moveCount % 3 == 0) {
          _shiftMazeLayout();
        }
      });
    }
  }

  void _showNotQuiteDialog() {
    _mazeShiftTimer?.cancel(); 
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      title: 'Not Quite!',
      desc: 'You found *a* path, but the maze shifts... Try again!',
      btnOkOnPress: () {
        _initializeMaze(); 
        _updateControlMap(); 
        _startMazeShiftTimer(); 
      },
      btnOkColor: Colors.blue,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  void _showEscapeDialog() {
    _mazeShiftTimer?.cancel(); 
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      title: 'The Maze is Within Your Mind',
      desc: 'There is no exit. You are forever lost in the Illogical Path.',
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _mazeShiftTimer?.cancel();
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
                    tooltip: 'Close Maze',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The Illogical Path',
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
                  'Moves: $_moveCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                // Maze Grid Display
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridSize,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _gridSize * _gridSize,
                      itemBuilder: (context, index) {
                        final row = index ~/ _gridSize;
                        final col = index % _gridSize;
                        final cellType = _maze[row][col];

                        Color cellColor;
                        if (cellType == 1) {
                          cellColor = Colors.deepPurple.shade900; 
                        } else if (cellType == 2) {
                          cellColor = Colors.amber.shade700; 
                        } else if (cellType == 3) {
                          cellColor = Colors.greenAccent; 
                        } else {
                          cellColor = Colors.deepPurple.shade500; 
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: cellColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _movePlayer(_controlMap['Up']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: Icon(
                        _controlMap['Up'] == 'Up'
                            ? Icons.arrow_upward
                            : _controlMap['Up'] == 'Down'
                            ? Icons.arrow_downward
                            : _controlMap['Up'] == 'Left'
                            ? Icons.arrow_back
                            : Icons.arrow_forward,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _movePlayer(_controlMap['Left']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                          ),
                          child: Icon(
                            _controlMap['Left'] == 'Up'
                                ? Icons.arrow_upward
                                : _controlMap['Left'] == 'Down'
                                ? Icons.arrow_downward
                                : _controlMap['Left'] == 'Left'
                                ? Icons.arrow_back
                                : Icons.arrow_forward,
                          ),
                        ),
                        const SizedBox(width: 50),
                        ElevatedButton(
                          onPressed: () => _movePlayer(_controlMap['Right']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(15),
                          ),
                          child: Icon(
                            _controlMap['Right'] == 'Up'
                                ? Icons.arrow_upward
                                : _controlMap['Right'] == 'Down'
                                ? Icons.arrow_downward
                                : _controlMap['Right'] == 'Left'
                                ? Icons.arrow_back
                                : Icons.arrow_forward,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _movePlayer(_controlMap['Down']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: Icon(
                        _controlMap['Down'] == 'Up'
                            ? Icons.arrow_upward
                            : _controlMap['Down'] == 'Down'
                            ? Icons.arrow_downward
                            : _controlMap['Down'] == 'Left'
                            ? Icons.arrow_back
                            : Icons.arrow_forward,
                      ),
                    ),
                  ],
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
