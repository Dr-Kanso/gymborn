// ignore_for_file: avoid_print

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class HealthService {
  final Health health = Health();

  // Available data types to read
  static final List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.EXERCISE_TIME,
  ];

  // Request authorization to access health data
  Future<bool> requestAuthorization() async {
    // First check for permissions
    if (Platform.isAndroid) {
      final permissionStatus = await Permission.activityRecognition.request();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }

    // Then request health permissions
    try {
      await health.requestAuthorization(types);
      return true;
    } catch (e) {
      print("Health authorization error: $e");
      return false;
    }
  }

  // Get step count
  Future<int> getStepCount(DateTime start, DateTime end) async {
    try {
      final steps = await health.getTotalStepsInInterval(start, end);
      return steps ?? 0;
    } catch (e) {
      print("Error getting steps: $e");
      return 0;
    }
  }

  // Get active energy burned (calories)
  Future<double> getCaloriesBurned(DateTime start, DateTime end) async {
    try {
      List<HealthDataPoint> calories = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );

      double total = 0;
      for (var point in calories) {
        total += (point.value as NumericHealthValue).numericValue;
      }

      return total;
    } catch (e) {
      print("Error getting calories: $e");
      return 0;
    }
  }

  // Get sleep duration in hours
  Future<double> getSleepDuration(DateTime start, DateTime end) async {
    try {
      List<HealthDataPoint> sleepData = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.SLEEP_ASLEEP],
      );

      double totalMinutes = 0;
      for (var point in sleepData) {
        // Duration between end time and start time in minutes
        totalMinutes +=
            point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
      }

      return totalMinutes / 60; // Convert to hours
    } catch (e) {
      print("Error getting sleep data: $e");
      return 0;
    }
  }

  // Get workouts
  Future<List<Map<String, dynamic>>> getWorkouts(
    DateTime start,
    DateTime end,
  ) async {
    try {
      List<HealthDataPoint> workouts = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.WORKOUT],
      );

      List<Map<String, dynamic>> result = [];
      for (var workout in workouts) {
        final value = workout.value as WorkoutHealthValue;
        result.add({
          'type': value.workoutActivityType.toString(),
          'startTime': workout.dateFrom,
          'endTime': workout.dateTo,
          'duration': workout.dateTo.difference(workout.dateFrom).inMinutes,
          'totalEnergyBurned': value.totalEnergyBurned,
          'totalDistance': value.totalDistance,
        });
      }

      return result;
    } catch (e) {
      print("Error getting workout data: $e");
      return [];
    }
  }

  // Get walking/running distance
  Future<double> getDistance(DateTime start, DateTime end) async {
    try {
      List<HealthDataPoint> distance = await health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.DISTANCE_WALKING_RUNNING],
      );

      double total = 0;
      for (var point in distance) {
        total += (point.value as NumericHealthValue).numericValue;
      }

      return total;
    } catch (e) {
      print("Error getting distance: $e");
      return 0;
    }
  }
}
