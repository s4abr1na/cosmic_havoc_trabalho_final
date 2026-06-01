import 'package:cosmic_havoc/overlays/game_over_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:cosmic_havoc/my_game.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); 

  final MyGame game = MyGame();

  runApp(GameWidget(game: game,
  overlayBuilderMap: {
    'GameOver': (context, MyGame game) => GameOverOverlay(game: game)
  
  },));
}