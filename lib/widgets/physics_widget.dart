import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;
import 'dart:async'; // For Timer

/// A custom widget that can be dragged by the user and is also
/// subject to a continuous physics simulation (chaotic gravity).
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
  late Animation<Alignment> _alignmentAnimation; // Correctly animates Alignment
  late Alignment _dragAlignment; // Tracks the current position of the widget
  late Alignment
  _gravityTarget; // The constantly shifting target for chaotic gravity
  late bool _isInverted; // State for input inversion
  Timer? _gravityTargetTimer; // Timer to periodically update gravity target

  @override
  void initState() {
    super.initState();
    // Initialize drag alignment to the center
    _dragAlignment = Alignment.center;
    // Initialize a random gravity target
    _gravityTarget = _generateRandomAlignment();
    // Initialize inversion state
    _isInverted = false;

    // Initialize the AnimationController.
    // No duration is set as physics simulations determine their own duration.
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        // Update the widget's position based on the animation value
        // Now _alignmentAnimation.value provides the correct Alignment
        setState(() {
          _dragAlignment = _alignmentAnimation.value;
        });
      });

    // Start the continuous chaotic gravity animation
    _runGravityAnimation();

    // Periodically update the gravity target to create chaotic motion
    _gravityTargetTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _gravityTarget = _generateRandomAlignment();
        // Restart the animation with the new target if it's not currently being dragged
        if (!_controller.isAnimating) {
          _runGravityAnimation();
        }
      });
    });
  }

  /// Generates a random Alignment within the screen bounds (-1.0 to 1.0 for x and y).
  Alignment _generateRandomAlignment() {
    final random = math.Random();
    return Alignment(
      (random.nextDouble() * 2 - 1), // x from -1.0 to 1.0
      (random.nextDouble() * 2 - 1), // y from -1.0 to 1.0
    );
  }

  /// Runs a SpringSimulation to move the widget towards the current gravity target.
  void _runGravityAnimation() {
    // Create a new Tween for Alignment animation
    _alignmentAnimation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment, // Start from the current position
        end: _gravityTarget, // Animate towards the gravity target
      ),
    );

    // Animate the controller with a SpringSimulation.
    // The SpringSimulation itself works on doubles, so we use the distance
    // between the current alignment and the target.
    _controller.animateWith(
      SpringSimulation(
        SpringDescription(
          mass: 1.0,
          stiffness: 100.0, // Adjust stiffness for more or less "snappiness"
          damping: 10.0, // Adjust damping for more or less "bounciness"
        ),
        0.0, // Start the simulation from 0.0 (representing the 'begin' of the Tween)
        1.0, // End the simulation at 1.0 (representing the 'end' of the Tween)
        0.0, // Initial velocity
      ),
    );
  }

  /// Handles the start of a pan gesture, deciding on input inversion.
  void _handlePanStart(DragStartDetails details) {
    _controller.stop(); // Stop the gravity animation when user takes control
    setState(() {
      // 50% chance to invert input for this gesture
      _isInverted = math.Random().nextDouble() < 0.5;
    });
  }

  /// Handles updates during a pan gesture, applying inversion if active.
  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      // Calculate effective delta based on inversion state
      final Offset effectiveDelta = _isInverted
          ? -details.delta
          : details.delta;

      // Update drag alignment based on effective delta
      _dragAlignment += Alignment(
        effectiveDelta.dx / (MediaQuery.of(context).size.width / 2),
        effectiveDelta.dy / (MediaQuery.of(context).size.height / 2),
      );
    });
  }

  /// Handles the end of a pan gesture, restarting gravity animation with fling.
  void _handlePanEnd(DragEndDetails details) {
    // Create a new Tween for Alignment animation, incorporating the fling velocity
    _alignmentAnimation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment, // Start from the current position
        end: _gravityTarget, // Animate towards the gravity target
      ),
    );

    // Restart the gravity animation, incorporating the user's release velocity
    // The initial velocity for SpringSimulation should be a double, representing
    // the "speed" of the animation, not the actual pixel velocity.
    // We'll use a scaled version of the fling velocity.
    final double flingVelocity =
        details.velocity.pixelsPerSecond.distance *
        0.001 *
        (_isInverted ? -1 : 1);

    _controller.animateWith(
      SpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0, // Start the simulation from 0.0
        1.0, // End the simulation at 1.0
        flingVelocity, // Initial velocity for the simulation
      ),
    );
  }

  /// Handles tap gestures, demonstrating a simple tap inversion.
  void _handleTap() {
    setState(() {
      // 50% chance to invert tap action
      _isInverted = math.Random().nextDouble() < 0.5;
      if (_isInverted) {
        // Example: Inverted action - print a frustrating message
        print('Tap Inverted! Your action was negated.');
      } else {
        // Example: Normal action - print a success message
        print('Tap successful!');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _gravityTargetTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the child in RepaintBoundary for performance optimization
    return RepaintBoundary(
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTap: _handleTap, // Add tap gesture handling
        child: Align(
          alignment: _dragAlignment,
          child: Container(
            // Adjusted size for phone screens
            width: 120, // Smaller width
            height: 120, // Smaller height
            decoration: BoxDecoration(
              color: widget.backgroundColor.withOpacity(0.8),
              // Make it circular to match the buttons on the home page
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
                ), // Smaller font size
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}