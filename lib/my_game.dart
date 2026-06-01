import 'dart:async';
import 'dart:math';

import 'package:cosmic_havoc/components/asteroid.dart';
import 'package:cosmic_havoc/components/player.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:cosmic_havoc/components/shoot_button.dart';
import 'package:flame/effects.dart';
import 'package:cosmic_havoc/components/pickup.dart';
import 'package:flutter/foundation.dart';
import 'package:cosmic_havoc/components/star.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection{
  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _asteroidSpawner;
  late SpawnComponent _pickupSpawner;
  final Random _random = Random();
  late ShootButton _shootButton;
  int _score = 0;
  late TextComponent _scoreDisplay;

  @override
  FutureOr<void> onLoad() async {
    if (!kIsWeb) { // 👈 adiciona
      await Flame.device.fullScreen();
      await Flame.device.setPortrait();
    }

    _createStars();
    await startGame(); // 👈 adiciona await

    return super.onLoad();
  }

  Future <void> startGame() async{
    await _createJoystick();
    await _createPlayer();
    _createShootButton();
    _createAsteroidSpawener();
    _createPickupSpawener();
    _createScoreDisplay();
  }

  Future<void> _createPlayer() async{
    player = Player()
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y * 0.8)
      ..size = Vector2.all(100);
    add(player);
  }
  
  Future<void> _createJoystick() async{
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: await loadSprite('joystick_knob.png'), 
        size: Vector2.all(50)
      ),
      background: SpriteComponent(
        sprite: await loadSprite('joystick_background.png'),
        size: Vector2.all(100),
      ),
      anchor: Anchor.bottomLeft,
      position: Vector2(20, size.y - 20),    
      priority: 10,
      );
    add(joystick);
  }

  void _createShootButton(){
    _shootButton = ShootButton()
    ..anchor = Anchor.bottomRight
    ..position =Vector2(size.x - 20, size.y - 20);
    add(_shootButton);
  }

  void _createAsteroidSpawener(){
    _asteroidSpawner = SpawnComponent.periodRange(
      factory: (index) => Asteroid(position: _generateSpawnPosition()),
      minPeriod: 0.7,
      maxPeriod: 1.2,
      selfPositioning: true,
    );
    add(_asteroidSpawner);
  }

  void _createPickupSpawener(){
    _pickupSpawner = SpawnComponent.periodRange(
      factory: (index) => Pickup(
        position: _generateSpawnPosition(),
        pickupType: 
          PickupType.values[_random.nextInt(PickupType.values.length)]
      ),
      minPeriod: 5.0,
      maxPeriod: 10.0,
      selfPositioning: true,
    );
    add(_pickupSpawner);
  }

  Vector2 _generateSpawnPosition(){
    return Vector2(
      10 + _random.nextDouble() * (size.x - 10 * 2),
      -100,
    );
  }

  void _createScoreDisplay(){
    _score = 0;

    _scoreDisplay = TextComponent(
      text: '0',
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 20),
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black, 
              offset: Offset(2,2),
              blurRadius: 2,
            ),
          ],
        ),    
      ),
    );

    add(_scoreDisplay);
  }

  void incrementScore(int amount){
    _score += amount;
    _scoreDisplay.text = _score.toString();
  
    final ScaleEffect popEffect = ScaleEffect.to(
      Vector2.all(1.2),
      EffectController(
        duration: 0.05,
        alternate: true,
        curve: Curves.easeInOut,
      ),
    );

    _scoreDisplay.add(popEffect);
  }

  void _createStars(){
    for(int i=0; i<50; i++){
      add(Star()..priority = -10);
    }
  }


  void playerDied(){
    overlays.add('GameOver');
    pauseEngine();
  }

  void restartGame(){
    children.whereType<PositionComponent>().forEach((component){
      if(component is Asteroid || component is Pickup){
        remove(component);
      }
    });

  _asteroidSpawner.timer.start();
  _pickupSpawner.timer.start();

  _score = 0;
  _scoreDisplay.text = '0';

  _createPlayer();

  resumeEngine();
  }
}