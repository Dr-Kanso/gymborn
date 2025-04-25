import 'dart:math';

import 'package:flame/components.dart';
import 'package:gymborn_app/game/gym_game.dart';
import 'entities/enemy.dart';

class EnemyController extends Component with HasGameReference<GymGame> {
  final Enemy enemy;
  final Random _random = Random();
  double _actionTimer = 0;
  double _actionInterval = 3.0; // Time between actions in seconds
  
  EnemyController({required this.enemy});
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Don't update behavior if enemy is dead or currently hurt/attacking
    if (enemy.isDead || 
        enemy.currentState == EnemyState.hurt || 
        enemy.currentState == EnemyState.slashing) {
      return;
    }
    
    // Update action timer
    _actionTimer += dt;
    
    // Take a random action when timer expires
    if (_actionTimer >= _actionInterval) {
      _takeRandomAction();
      _actionTimer = 0;
      _actionInterval = _random.nextDouble() * 2 + 2; // Between 2-4 seconds
    }
  }
  
  void _takeRandomAction() {
    // Choose a random action based on weights
    // 60% chance to attack, 40% chance to run
    if (_random.nextDouble() < 0.6) {
      enemy.attack();
    } else {
      enemy.startRunning();
      // Run for a short duration, then return to idle
      Future.delayed(Duration(milliseconds: 1500), () {
        if (enemy.currentState == EnemyState.running) {
          enemy.changeState(EnemyState.idle);
        }
      });
    }
  }
  
  // Method to test enemy hurt animation
  void hitEnemy(double damage) {
    enemy.takeDamage(damage);
  }
}
