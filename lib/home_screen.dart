import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_fireworks/fireworks_controller.dart';
import 'package:flutter_fireworks/fireworks_display.dart';
import 'package:useless/button/chaos_cube/unstable_tower.dart';
import 'package:useless/button/crossword/crossword_screen.dart';
import 'package:useless/button/eternal_enigma/shifting_pattern.dart';
import 'package:useless/button/logical_labyrinth/paradoxical_sequence.dart';
import 'package:useless/button/mind_maze/llogical_path_game.dart';
import 'package:useless/widgets/physics_widget.dart';

class PuzzleHomePage extends StatefulWidget {
  const PuzzleHomePage({super.key});

  @override
  State<PuzzleHomePage> createState() => _PuzzleHomePageState();
}

class _PuzzleHomePageState extends State<PuzzleHomePage> {

  final fireworksController = FireworksController(
    colors: [
      const Color(0xFFFF4C40), 
      const Color(0xFF6347A6), 
      const Color(0xFF7FB13B), 
      const Color(0xFF82A0D1), 
      const Color(0xFFF7B3B2), 
      const Color(0xFF864542), 
      const Color(0xFFB04A98), 
      const Color(0xFF008F6C), 
      const Color(0xFFFFFF33), 
      const Color(0xFFFF6F7C), 
    ],
    minExplosionDuration: 0.5,
    maxExplosionDuration: 3.5,
    minParticleCount: 125,
    maxParticleCount: 275,
    fadeOutDuration: 0.4,
  );

  void _showMiseryDialog() {
    AwesomeDialog(
      context: context,
      dialogType:
          DialogType.noHeader, 
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      title: 'Heheheee ',
      desc: 'You can\'t leave that easily 😜',
      btnOkOnPress:
          () {}, 
      btnOkColor: Colors.red, 
      dismissOnTouchOutside: false, 
      dismissOnBackKeyPress: false, 
    ).show();
  }

  void _showFakeGameDialog(String gameName) {
    
    Widget gameScreen;
    switch (gameName) {
      case 'Mind Maze':
        gameScreen = const IllogicalPathGameScreen();
        break;
      case 'Logic Labyrinth':
        gameScreen = const ParadoxicalSequenceGameScreen();
        break;
      case 'Riddle Realm':
        gameScreen = const RiddleRealmScreen();
        break;
      case 'Chaos Cubes':
        gameScreen = const UnstableTowerGameScreen();
        break;
      case 'Eternal Enigma':
        gameScreen = const ShiftingPatternGameScreen();
        break;
      default:
        
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          animType: AnimType.scale,
          headerAnimationLoop: false,
          title: gameName,
          desc: 'This game is just as useless as your attempt to leave.',
          btnOkOnPress: () {}, 
          btnOkColor: Colors.grey,
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
        ).show();
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: gameScreen,
        );
      },
    );
  }

  @override
  void dispose() {
    fireworksController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          
          FireworksDisplay(controller: fireworksController),

          
          Align(
            alignment: const Alignment(0.7, -0.3), 
            child: PhysicsWidget(
              backgroundColor: Colors.indigo.shade400,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.all(16),
                        child: LoginScreen(), 
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade400,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(), 
                  padding: const EdgeInsets.all(
                    0,
                  ), 
                ),
                child: const Text(
                  'Login Field?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),


          Align(
            alignment: const Alignment(
              0.0,
              0.7,
            ), 
            child: PhysicsWidget(
              backgroundColor: Colors.amber.shade700,
              child: ElevatedButton.icon(
                onPressed: () => fireworksController.fireMultipleRockets(
                  minRockets: 5,
                  maxRockets: 15,
                  launchWindow: const Duration(milliseconds: 500),
                ),
                label: const Text('Fireworks!'),
                icon: const Icon(Icons.celebration),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
              ),
            ),
          ),

          
          Align(
            alignment: const Alignment(
              -0.7,
              -0.3,
            ), 
            child: PhysicsWidget(
              backgroundColor: Colors.green.shade700,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.all(16),
                        child: CrosswordScreen(),
                      );
                    },
                  );
                },
                label: const Text('Crossword'),
                icon: const Icon(Icons.grid_on),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
              ),
            ),
          ),

          
          Align(
            alignment: const Alignment(
              0.7,
              0.3,
            ), 
            child: PhysicsWidget(
              backgroundColor: Colors.grey.shade800,
              child: ElevatedButton(
                onPressed: _showMiseryDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Text(
                  'Click to end your misery',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),

          
          Align(
            alignment: const Alignment(-0.9, -0.8), 
            child: PhysicsWidget(
              backgroundColor: Colors.blueGrey.shade700,
              child: ElevatedButton(
                onPressed: () => _showFakeGameDialog('Mind Maze'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Text(
                  'Mind Maze',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.9, -0.8), 
            child: PhysicsWidget(
              backgroundColor: Colors.deepOrange.shade700,
              child: ElevatedButton(
                onPressed: () => _showFakeGameDialog('Logic Labyrinth'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade700,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Text(
                  'Logic Labyrinth',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.9, 0.8), 
            child: PhysicsWidget(
              backgroundColor: Colors.teal.shade700,
              child: ElevatedButton(
                onPressed: () => _showFakeGameDialog('Riddle Realm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Text(
                  'Riddle Realm',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.9, 0.8),  
            child: PhysicsWidget(
              backgroundColor: Colors.redAccent.shade700,
              child: ElevatedButton(
                onPressed: () => _showFakeGameDialog('Chaos Cubes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade700,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Text(
                  'Chaos Cubes',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, -0.0),
            child: PhysicsWidget(
              backgroundColor: Colors.purple.shade700,
              child: ElevatedButton(
                onPressed: () => _showFakeGameDialog('Eternal Enigma'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                ),
                child: const Text(
                  'Eternal Enigma',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RiddleRealmScreen {
  const RiddleRealmScreen();
}