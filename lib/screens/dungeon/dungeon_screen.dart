import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../providers/gym_provider.dart';
import '../../themes/theme.dart';

class DungeonScreen extends StatefulWidget {
  const DungeonScreen({super.key});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  final List<Map<String, dynamic>> _availableDungeons = [
    {
      'name': 'Iron Temple',
      'type': 'STR',
      'level': 1,
      'description': 'Test your strength in the ancient Iron Temple.',
      'rewards': ['Strength Crystal', 'Iron Ore', 'Dungeon Card'],
      'color': kStrColor,
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Endless Paths',
      'type': 'END',
      'level': 1,
      'description': 'Navigate the winding Endless Paths to improve endurance.',
      'rewards': ['Endurance Crystal', 'Swift Essence', 'Dungeon Card'],
      'color': kEndColor,
      'icon': Icons.directions_run,
    },
    {
      'name': 'Mystic Meditation Cave',
      'type': 'WIS',
      'level': 1,
      'description': 'Seek wisdom in the tranquil Meditation Cave.',
      'rewards': ['Wisdom Crystal', 'Ancient Scroll', 'Dungeon Card'],
      'color': kWisColor,
      'icon': Icons.self_improvement,
    },
    {
      'name': 'Restorative Pools',
      'type': 'REC',
      'level': 1,
      'description': 'Relax in the healing waters of the Restorative Pools.',
      'rewards': ['Recovery Crystal', 'Pure Water', 'Dungeon Card'],
      'color': kRecColor,
      'icon': Icons.bedtime,
    },
  ];

  bool _isCheckedIn = false;
  Map<String, dynamic>? _selectedDungeon;

  @override
  void initState() {
    super.initState();
    _checkGymStatus();
  }

  void _checkGymStatus() {
    final gymProvider = Provider.of<GymProvider>(context, listen: false);
    setState(() {
      _isCheckedIn = gymProvider.isCheckedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text('Dungeons')),
      body: _isCheckedIn ? _buildDungeonsList() : _buildNotCheckedInMessage(),
    );
  }

  Widget _buildDungeonsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: kPrimaryColor.withAlpha(
            (0.1 * 255).round(),
          ), // Changed from withOpacity
          child: Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Complete daily dungeons to earn materials and cards. Each dungeon type focuses on a different stat.',
                  style: TextStyle(color: kTextColor, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _selectedDungeon == null
                  ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _availableDungeons.length,
                    itemBuilder: (context, index) {
                      final dungeon = _availableDungeons[index];
                      return _buildDungeonCard(dungeon);
                    },
                  )
                  : _buildSelectedDungeonView(),
        ),
      ],
    );
  }

  Widget _buildDungeonCard(Map<String, dynamic> dungeon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDungeon = dungeon;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: dungeon['color'].withAlpha(
                        (0.2 * 255).round(),
                      ), // Changed from withOpacity
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      dungeon['icon'],
                      color: dungeon['color'],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dungeon['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                        Text(
                          'Level ${dungeon['level']} - ${dungeon['type']} Dungeon',
                          style: TextStyle(
                            fontSize: 14,
                            color: kLightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: kLightTextColor),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dungeon['description'],
                style: TextStyle(fontSize: 14, color: kTextColor),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Rewards: ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      dungeon['rewards'].join(', '),
                      style: TextStyle(fontSize: 14, color: kLightTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDungeonView() {
    final dungeon = _selectedDungeon!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedDungeon = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Dungeon Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dungeon image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: dungeon['color'].withAlpha(
                (0.2 * 255).round(),
              ), // Changed from withOpacity
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(dungeon['icon'], size: 72, color: dungeon['color']),
            ),
          ),

          const SizedBox(height: 24),

          // Dungeon name and type
          Text(
            dungeon['name'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          Text(
            'Level ${dungeon['level']} - ${dungeon['type']} Dungeon',
            style: TextStyle(
              fontSize: 16,
              color: dungeon['color'],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dungeon['description'],
            style: TextStyle(fontSize: 16, color: kTextColor),
          ),

          const SizedBox(height: 16),

          // Rewards
          Text(
            'Rewards',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(dungeon['rewards'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: dungeon['color'].withAlpha(
                        (0.2 * 255).round(),
                      ), // Changed from withOpacity
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getRewardIcon(dungeon['rewards'][index]),
                      color: dungeon['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dungeon['rewards'][index],
                    style: TextStyle(fontSize: 16, color: kTextColor),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // Enter button
          CustomButton(
            text: 'Enter Dungeon',
            onPressed: () {
              _showDungeonEntryDialog(dungeon);
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon(String reward) {
    if (reward.contains('Crystal')) return Icons.diamond;
    if (reward.contains('Card')) return Icons.style;
    if (reward.contains('Ore')) return Icons.view_in_ar;
    if (reward.contains('Essence')) return Icons.flash_on;
    if (reward.contains('Scroll')) return Icons.menu_book;
    if (reward.contains('Water')) return Icons.opacity;
    return Icons.star;
  }

  void _showDungeonEntryDialog(Map<String, dynamic> dungeon) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Enter ${dungeon['name']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(dungeon['icon'], size: 48, color: dungeon['color']),
                const SizedBox(height: 16),
                Text(
                  'Are you ready to enter this dungeon? The challenge will begin immediately.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommended: ${dungeon['type']} 15+',
                  style: TextStyle(fontSize: 14, color: kLightTextColor),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Navigate to dungeon game or show placeholder
                  _showPlaceholderDungeonGameDialog(dungeon);
                },
                child: const Text('ENTER'),
              ),
            ],
          ),
    );
  }

  void _showPlaceholderDungeonGameDialog(Map<String, dynamic> dungeon) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('${dungeon['name']} Challenge'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Dungeon gameplay will be implemented here using the Flame engine.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Victory!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: dungeon['color'],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You completed the dungeon and earned rewards:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...List.generate(dungeon['rewards'].length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getRewardIcon(dungeon['rewards'][index]),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(dungeon['rewards'][index]),
                      ],
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('COLLECT REWARDS'),
              ),
            ],
          ),
    );
  }

  Widget _buildNotCheckedInMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: kLightTextColor),
            const SizedBox(height: 24),
            Text(
              'Check-In Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You need to check in to a gym to access dungeons. Dungeons are only available when you\'re at the gym!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: kLightTextColor),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Go to Check-In',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/gym-checkin');
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }
}
