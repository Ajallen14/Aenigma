import 'package:flutter/material.dart';
import 'dart:async';

import 'package:useless/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late Animation<double> _titleScaleAnimation;
  late Animation<Color?> _backgroundAnimation;

  late Timer _movementTimer;
  int _movementStep = -1;
  int _pressCount = 0;
  bool _isButtonAnimating = false;

  double _buttonTop = 0;
  double _buttonLeft = 0;
  final double _buttonWidth = 250;
  final double _buttonHeight = 60;
  final double _bottomPadding = 50.0;

  @override
  void initState() {
    super.initState();

    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _titleScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _backgroundAnimation =
        ColorTween(
          begin: Colors.deepPurple.shade900,
          end: Colors.indigo.shade900,
        ).animate(
          CurvedAnimation(
            parent: _titleAnimationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
          ),
        );

    _titleAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetButtonPosition();
    });
  }

  void _resetButtonPosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    setState(() {
      _buttonTop = screenHeight - _buttonHeight - _bottomPadding;
      _buttonLeft = (screenWidth - _buttonWidth) / 2;
    });
  }

  void _startButtonMovement() {
    _movementStep = 0;
    _isButtonAnimating = true;

    _movementTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      const margin = 20.0;

      setState(() {
        if (_movementStep == 0) {
          _buttonTop = margin;
          _buttonLeft = margin;
        } else if (_movementStep == 1) {
          _buttonTop = margin;
          _buttonLeft = screenWidth - _buttonWidth - margin;
        } else if (_movementStep == 2) {
          _buttonTop = screenHeight - _buttonHeight - margin;
          _buttonLeft = screenWidth - _buttonWidth - margin;
        } else if (_movementStep == 3) {
          _buttonTop = screenHeight - _buttonHeight - margin;
          _buttonLeft = margin;
        } else if (_movementStep == 4) {
          _resetButtonPosition();
          _isButtonAnimating = false;
          timer.cancel();
        }
        _movementStep++;
      });
    });
  }

  void _onButtonPressed() {
    if (_pressCount == 0 && !_isButtonAnimating) {
      _pressCount++;
      _startButtonMovement();
    } else if (_pressCount == 1 && !_isButtonAnimating) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PuzzleHomePage()),
      );
    }
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    if (_movementTimer.isActive) {
      _movementTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _titleAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [_backgroundAnimation.value!, Colors.black],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _titleScaleAnimation,
                        child: Text(
                          'Aenigma',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Inter',
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.purple.shade300,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedOpacity(
                        opacity: _titleAnimationController.value > 0.5
                            ? 1.0
                            : 0.0,
                        duration: const Duration(seconds: 1),
                        child: Text(
                          'Are you ready to start your misery?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  top: _buttonTop,
                  left: _buttonLeft,
                  width: _buttonWidth,
                  height: _buttonHeight,
                  child: ElevatedButton(
                    onPressed: _onButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonAnimating
                          ? Colors.redAccent.withOpacity(0.5)
                          : Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      _pressCount == 0
                          ? 'Begin'
                          : _isButtonAnimating
                          ? 'Wait...'
                          : 'Press Again',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isButtonAnimating
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
