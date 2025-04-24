import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../services/health_service.dart';

class StatsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final HealthService _healthService = HealthService();

  Stats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  Stats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize stats without immediate notification
  void initStats(GymBornUser user) {
    if (_stats?.toString() != user.stats.toString()) {
      _stats = user.stats;
      // Schedule notification for the next frame to avoid build-phase notification
      Future.microtask(() => notifyListeners());
    }
  }

  // Set stats without notification (for initial setup)
  void setStatsWithoutNotify(Stats stats) {
    _stats = stats;
  }

  // Helper for setting loading state safely
  void setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    Future.microtask(() => notifyListeners());
  }

  // Helper for setting error message safely
  void setError(String? message) {
    if (_errorMessage == message) return;
    _errorMessage = message;
    Future.microtask(() => notifyListeners());
  }

  // Update stats based on workout
  Future<bool> updateStatsFromWorkout({
    required String userId,
    required Map<String, dynamic> workoutData,
    required String statType,
    required int gainAmount,
  }) async {
    if (_stats == null) return false;

    setLoading(true);
    setError(null);

    try {
      // Update stats based on workout type
      Stats updatedStats;

      switch (statType) {
        case 'STR':
          updatedStats = _stats!.copyWith(
            strength: _stats!.strength + gainAmount,
          );
          break;
        case 'END':
          updatedStats = _stats!.copyWith(
            endurance: _stats!.endurance + gainAmount,
          );
          break;
        case 'WIS':
          updatedStats = _stats!.copyWith(wisdom: _stats!.wisdom + gainAmount);
          break;
        case 'REC':
          updatedStats = _stats!.copyWith(
            recovery: _stats!.recovery + gainAmount,
          );
          break;
        default:
          setError('Invalid stat type');
          return false;
      }

      // Update Firestore
      await _firestoreService.updateStats(userId, updatedStats);

      // Log the workout
      await _firestoreService.logWorkout(userId, {
        ...workoutData,
        'statType': statType,
        'gainAmount': gainAmount,
      });

      // Update local stats
      _stats = updatedStats;
      notifyListeners();
      return true;
    } catch (error) {
      setError('Failed to update stats: $error');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Calculate stat gains from health data
  Future<Map<String, int>> calculateStatsFromHealthData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    setLoading(true);
    setError(null);

    try {
      // Request authorization
      bool isAuthorized = await _healthService.requestAuthorization();
      if (!isAuthorized) {
        setError('Health data access not authorized');
        return {};
      }

      // Get health data for different stats
      Map<String, int> statGains = {};

      // Steps -> END stat
      int steps = await _healthService.getStepCount(startDate, endDate);
      int endGain = (steps / 1000).floor(); // 1 END per 1000 steps
      if (endGain > 0) statGains['END'] = endGain;

      // Calories -> STR stat
      double calories = await _healthService.getCaloriesBurned(
        startDate,
        endDate,
      );
      int strGain = (calories / 200).floor(); // 1 STR per 200 active calories
      if (strGain > 0) statGains['STR'] = strGain;

      // Sleep -> REC stat
      double sleepHours = await _healthService.getSleepDuration(
        startDate,
        endDate,
      );
      int recGain = (sleepHours / 2).floor(); // 1 REC per 2 hours of sleep
      if (recGain > 0) statGains['REC'] = recGain;

      // Workouts
      List<Map<String, dynamic>> workouts = await _healthService.getWorkouts(
        startDate,
        endDate,
      );

      for (var workout in workouts) {
        if (workout['type'].toString().contains('YOGA') ||
            workout['type'].toString().contains('MEDITATION')) {
          // Meditation/Yoga -> WIS stat
          int wisGain =
              (workout['duration'] / 10).floor(); // 1 WIS per 10 minutes
          statGains['WIS'] = (statGains['WIS'] ?? 0) + wisGain;
        }
      }

      return statGains;
    } catch (error) {
      setError('Failed to retrieve health data: $error');
      return {};
    } finally {
      setLoading(false);
    }
  }

  // Apply health data stats to user
  Future<bool> applyHealthDataStats(
    String userId,
    Map<String, int> statGains,
  ) async {
    if (_stats == null) return false;

    setLoading(true);
    setError(null);

    try {
      Stats updatedStats = Stats(
        strength: _stats!.strength + (statGains['STR'] ?? 0),
        endurance: _stats!.endurance + (statGains['END'] ?? 0),
        wisdom: _stats!.wisdom + (statGains['WIS'] ?? 0),
        recovery: _stats!.recovery + (statGains['REC'] ?? 0),
      );

      await _firestoreService.updateStats(userId, updatedStats);

      // Update local stats
      _stats = updatedStats;
      notifyListeners();
      return true;
    } catch (error) {
      setError('Failed to apply health data stats: $error');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Manual stat update (for testing or admin purposes)
  Future<bool> manuallyUpdateStat(
    String userId,
    String statType,
    int value,
  ) async {
    if (_stats == null) return false;

    setLoading(true);
    setError(null);

    try {
      Stats updatedStats;

      switch (statType) {
        case 'STR':
          updatedStats = _stats!.copyWith(strength: value);
          break;
        case 'END':
          updatedStats = _stats!.copyWith(endurance: value);
          break;
        case 'WIS':
          updatedStats = _stats!.copyWith(wisdom: value);
          break;
        case 'REC':
          updatedStats = _stats!.copyWith(recovery: value);
          break;
        default:
          setError('Invalid stat type');
          return false;
      }

      await _firestoreService.updateStats(userId, updatedStats);

      _stats = updatedStats;
      notifyListeners();
      return true;
    } catch (error) {
      setError('Failed to update stats: $error');
      return false;
    } finally {
      setLoading(false);
    }
  }
}
