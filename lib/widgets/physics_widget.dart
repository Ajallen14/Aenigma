import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;
import 'dart:async';

class PhysicsWidget extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;

  const PhysicsWidget({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.blueGrey,
  }) : super(key: key);

  @override
  _PhysicsWidgetState createState() => _PhysicsWidgetState();
}

class _PhysicsWidgetState extends State<PhysicsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;
  late Alignment _dragAlignment;
  late Alignment
  _gravityTarget;
  late bool _isInverted;
  Timer? _gravityTargetTimer;

  @override
  void initState() {
    super.initState();
    _dragAlignment = Alignment.center;
    _gravityTarget = _generateRandomAlignment();
    _isInverted = false;

    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          _dragAlignment = _alignmentAnimation.value;
        });
      });

    _runGravityAnimation();

    _gravityTargetTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _gravityTarget = _generateRandomAlignment();
        if (!_controller.isAnimating) {
          _runGravityAnimation();
        }
      });
    });
  }

  Alignment _generateRandomAlignment() {
    final random = math.Random();
    return Alignment(
      (random.nextDouble() * 2 - 1),
      (random.nextDouble() * 2 - 1),
    );
  }

  void _runGravityAnimation() {
    _alignmentAnimation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: _gravityTarget,
      ),
    );

    _controller.animateWith(
      SpringSimulation(
        SpringDescription(
          mass: 1.0,
          stiffness: 100.0,
          damping: 10.0,
        ),
        0.0,
        1.0,
        0.0,
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    _controller.stop();
    setState(() {
      _isInverted = math.Random().nextDouble() < 0.5;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      final Offset effectiveDelta = _isInverted
          ? -details.delta
          : details.delta;

      _dragAlignment += Alignment(
        effectiveDelta.dx / (MediaQuery.of(context).size.width / 2),
        effectiveDelta.dy / (MediaQuery.of(context).size.height / 2),
      );
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _alignmentAnimation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: _gravityTarget,
      ),
    );

    final double flingVelocity =
        details.velocity.pixelsPerSecond.distance *
        0.001 *
        (_isInverted ? -1 : 1);

    _controller.animateWith(
      SpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        flingVelocity,
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _isInverted = math.Random().nextDouble() < 0.5;
      if (_isInverted) {
        print('Tap Inverted! Your action was negated.');
      } else {
        print('Tap successful!');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _gravityTargetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTap: _handleTap,
        child: Align(
          alignment: _dragAlignment,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: widget.backgroundColor.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}