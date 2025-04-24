import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../components/stat_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../themes/theme.dart';
import '../../models/stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final statsProvider = Provider.of<StatsProvider>(context);
    final stats = statsProvider.stats;

    if (stats == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Stats & Progress'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kLightTextColor,
          indicatorColor: kPrimaryColor,
          tabs: const [Tab(text: 'Your Stats'), Tab(text: 'Log Activity')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(stats),
          _buildLogActivityTab(authProvider.user!.uid, stats),
        ],
      ),
    );
  }

  Widget _buildStatsTab(Stats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 16),
          StatCard.str(value: stats.strength, isExpanded: true),
          const SizedBox(height: 16),
          StatCard.end(value: stats.endurance, isExpanded: true),
          const SizedBox(height: 16),
          StatCard.wis(value: stats.wisdom, isExpanded: true),
          const SizedBox(height: 16),
          StatCard.rec(value: stats.recovery, isExpanded: true),
          const SizedBox(height: 24),
          Text(
            'Total Level: ${stats.totalLevel}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRoleProgress(
                    'Vanguard',
                    'STR ≥ 40, END ≥ 35',
                    stats.strength >= 40 && stats.endurance >= 35,
                  ),
                  _buildRoleProgress(
                    'Breaker',
                    'STR ≥ 50',
                    stats.strength >= 50,
                  ),
                  _buildRoleProgress(
                    'Windstrider',
                    'END ≥ 50',
                    stats.endurance >= 50,
                  ),
                  _buildRoleProgress('Mystic', 'WIS ≥ 45', stats.wisdom >= 45),
                  _buildRoleProgress(
                    'Sage',
                    'WIS ≥ 35, REC ≥ 30',
                    stats.wisdom >= 35 && stats.recovery >= 30,
                  ),
                  _buildRoleProgress(
                    'Verdant',
                    'REC ≥ 35, WIS ≥ 25',
                    stats.recovery >= 35 && stats.wisdom >= 25,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRoleProgress(
    String roleName,
    String requirements,
    bool isUnlocked,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isUnlocked
                      ? kSecondaryColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isUnlocked ? Icons.check : Icons.lock_outline,
              color: isUnlocked ? kSecondaryColor : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked ? kTextColor : kLightTextColor,
                  ),
                ),
                Text(
                  requirements,
                  style: TextStyle(fontSize: 12, color: kLightTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogActivityTab(String userId, Stats currentStats) {
    final statsProvider = Provider.of<StatsProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record your workouts and activities to gain stats',
            style: TextStyle(fontSize: 14, color: kLightTextColor),
          ),
          const SizedBox(height: 24),

          // Manual workout logging
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual Entry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // STR Workout
                  _buildWorkoutLogTile(
                    'Strength Training',
                    'Resistance exercises, weight lifting',
                    Icons.fitness_center,
                    kStrColor,
                    () async {
                      bool success = await statsProvider.updateStatsFromWorkout(
                        userId: userId,
                        workoutData: {
                          'type': 'strength_training',
                          'duration': 45, // minutes
                        },
                        statType: 'STR',
                        gainAmount: 3,
                      );

                      _showResultSnackbar(success, 'STR +3');
                    },
                  ),

                  // END Workout
                  _buildWorkoutLogTile(
                    'Cardio',
                    'Running, cycling, swimming',
                    Icons.directions_run,
                    kEndColor,
                    () async {
                      bool success = await statsProvider.updateStatsFromWorkout(
                        userId: userId,
                        workoutData: {
                          'type': 'cardio',
                          'duration': 30, // minutes
                        },
                        statType: 'END',
                        gainAmount: 2,
                      );

                      _showResultSnackbar(success, 'END +2');
                    },
                  ),

                  // WIS Workout
                  _buildWorkoutLogTile(
                    'Mind & Focus',
                    'Yoga, meditation, mental training',
                    Icons.self_improvement,
                    kWisColor,
                    () async {
                      bool success = await statsProvider.updateStatsFromWorkout(
                        userId: userId,
                        workoutData: {
                          'type': 'meditation',
                          'duration': 20, // minutes
                        },
                        statType: 'WIS',
                        gainAmount: 2,
                      );

                      _showResultSnackbar(success, 'WIS +2');
                    },
                  ),

                  // REC Workout
                  _buildWorkoutLogTile(
                    'Recovery',
                    'Sleep, stretching, relaxation',
                    Icons.bedtime,
                    kRecColor,
                    () async {
                      bool success = await statsProvider.updateStatsFromWorkout(
                        userId: userId,
                        workoutData: {
                          'type': 'recovery',
                          'duration': 480, // minutes (8 hours sleep)
                        },
                        statType: 'REC',
                        gainAmount: 2,
                      );

                      _showResultSnackbar(success, 'REC +2');
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Health App Sync
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sync Health Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect to your health app to automatically sync your activities',
                    style: TextStyle(fontSize: 14, color: kLightTextColor),
                  ),
                  const SizedBox(height: 16),

                  // Date Range Picker
                  Row(
                    children: [
                      Icon(Icons.date_range, color: kLightTextColor),
                      const SizedBox(width: 8),
                      Text(
                        '${_startDate.day}/${_startDate.month} - ${_endDate.day}/${_endDate.month}',
                        style: TextStyle(fontSize: 14, color: kTextColor),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final DateTimeRange? picked =
                              await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 30),
                                ),
                                lastDate: DateTime.now(),
                                initialDateRange: DateTimeRange(
                                  start: _startDate,
                                  end: _endDate,
                                ),
                              );

                          if (picked != null) {
                            setState(() {
                              _startDate = picked.start;
                              _endDate = picked.end;
                            });
                          }
                        },
                        child: Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'Sync Health Data',
                    icon: Icons.sync,
                    onPressed: () async {
                      final statsProvider = Provider.of<StatsProvider>(
                        context,
                        listen: false,
                      );

                      // Calculate stats from health data
                      Map<String, int> statGains = await statsProvider
                          .calculateStatsFromHealthData(_startDate, _endDate);

                      if (statGains.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No health data found for the selected period',
                            ),
                          ),
                        );
                        return;
                      }

                      // Apply the stats
                      bool success = await statsProvider.applyHealthDataStats(
                        userId,
                        statGains,
                      );

                      // Show result
                      String message = '';
                      statGains.forEach((stat, value) {
                        message += '$stat +$value ';
                      });

                      _showResultSnackbar(success, message);
                    },
                    isLoading: statsProvider.isLoading,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutLogTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: kLightTextColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  void _showResultSnackbar(bool success, String statChange) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              success
                  ? 'Activity logged successfully! $statChange'
                  : 'Failed to log activity. Please try again.',
            ),
          ],
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
