import 'package:flutter/material.dart';
import '../themes/theme.dart';

class StatCard extends StatelessWidget {
  final String statName;
  final int statValue;
  final Color statColor;
  final IconData icon;
  final bool showProgress;
  final int? nextMilestone;
  final bool isExpanded;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.statName,
    required this.statValue,
    required this.statColor,
    required this.icon,
    this.showProgress = true,
    this.nextMilestone,
    this.isExpanded = false,
    this.onTap,
  });

  factory StatCard.str({
    required int value,
    bool showProgress = true,
    int? nextMilestone,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    return StatCard(
      statName: 'STR',
      statValue: value,
      statColor: kStrColor,
      icon: Icons.fitness_center,
      showProgress: showProgress,
      nextMilestone: nextMilestone,
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }

  factory StatCard.end({
    required int value,
    bool showProgress = true,
    int? nextMilestone,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    return StatCard(
      statName: 'END',
      statValue: value,
      statColor: kEndColor,
      icon: Icons.directions_run,
      showProgress: showProgress,
      nextMilestone: nextMilestone,
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }

  factory StatCard.wis({
    required int value,
    bool showProgress = true,
    int? nextMilestone,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    return StatCard(
      statName: 'WIS',
      statValue: value,
      statColor: kWisColor,
      icon: Icons.self_improvement,
      showProgress: showProgress,
      nextMilestone: nextMilestone,
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }

  factory StatCard.rec({
    required int value,
    bool showProgress = true,
    int? nextMilestone,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    return StatCard(
      statName: 'REC',
      statValue: value,
      statColor: kRecColor,
      icon: Icons.bedtime,
      showProgress: showProgress,
      nextMilestone: nextMilestone,
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: statColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    statValue.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statColor,
                    ),
                  ),
                ],
              ),
              if (showProgress && nextMilestone != null) ...[
                const SizedBox(height: 12),
                _buildProgressBar(),
              ],
              if (isExpanded) ...[
                const SizedBox(height: 16),
                _buildExpandedContent(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final int milestone = nextMilestone ?? (statValue + 10);
    final double progress = statValue / milestone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(statColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          'Next milestone: $milestone',
          style: TextStyle(fontSize: 12, color: kLightTextColor),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    String description = '';
    List<String> benefits = [];

    switch (statName) {
      case 'STR':
        description = 'Strength increases with resistance training.';
        benefits = [
          'Unlock Vanguard role at 40 STR',
          'Unlock Breaker role at 50 STR',
          'Boost weapon crafting at 30 STR',
        ];
        break;
      case 'END':
        description = 'Endurance increases with cardio exercises.';
        benefits = [
          'Unlock Vanguard role at 35 END',
          'Unlock Windstrider role at 50 END',
          'Faster dungeon recovery at 40 END',
        ];
        break;
      case 'WIS':
        description = 'Wisdom increases with meditation and yoga.';
        benefits = [
          'Unlock Mystic role at 45 WIS',
          'Unlock Sage role at 35 WIS',
          'Boost potion effectiveness at 30 WIS',
        ];
        break;
      case 'REC':
        description = 'Recovery increases with proper rest and sleep.';
        benefits = [
          'Unlock Sage role at 30 REC',
          'Unlock Verdant role at 35 REC',
          'Faster health regeneration at 40 REC',
        ];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: TextStyle(fontSize: 14, color: kLightTextColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Benefits:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 4),
        ...benefits.map(
          (benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: statColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(fontSize: 13, color: kLightTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
