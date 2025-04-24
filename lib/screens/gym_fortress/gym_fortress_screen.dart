import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../themes/theme.dart';

class GymFortressScreen extends StatefulWidget {
  const GymFortressScreen({super.key});

  @override
  State<GymFortressScreen> createState() => _GymFortressScreenState();
}

class _GymFortressScreenState extends State<GymFortressScreen> {
  // Currently selected theme for the fortress
  String _currentTheme = 'Moonlight Garden';

  // Available themes
  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Moonlight Garden',
      'description':
          'A tranquil garden bathed in soft moonlight with glowing flowers and calm ponds.',
      'premiumRequired': false,
      'color': kWisColor,
      'icon': Icons.nightlight_round,
    },
    {
      'name': 'Crystal Lab',
      'description':
          'A modern laboratory filled with glowing crystals and magical equipment.',
      'premiumRequired': false,
      'color': kPrimaryColor,
      'icon': Icons.science,
    },
    {
      'name': 'Cozy Studio',
      'description':
          'A warm, comfortable space with wooden accents and soft lighting.',
      'premiumRequired': false,
      'color': kRecColor,
      'icon': Icons.weekend,
    },
    {
      'name': 'Celestial Observatory',
      'description':
          'An elegant observatory with star maps and cosmic decorations.',
      'premiumRequired': true,
      'color': Colors.indigo,
      'icon': Icons.star,
    },
    {
      'name': 'Ancient Library',
      'description':
          'A vast collection of mystical tomes and scrolls with magical lighting.',
      'premiumRequired': true,
      'color': Colors.brown,
      'icon': Icons.book,
    },
  ];

  // Available rooms in the fortress
  final List<Map<String, dynamic>> _rooms = [
    {
      'name': 'Meditation Hall',
      'description': 'A quiet space for meditation and yoga. +5% WIS gain.',
      'level': 2,
      'maxLevel': 5,
      'icon': Icons.self_improvement,
      'color': kWisColor,
      'upgradeCost': 500,
    },
    {
      'name': 'Forge',
      'description': 'Craft weapons and armor. +10% smithing efficiency.',
      'level': 1,
      'maxLevel': 5,
      'icon': Icons.fitness_center,
      'color': kStrColor,
      'upgradeCost': 750,
    },
    {
      'name': 'Garden',
      'description': 'Grow herbs and magical plants. +8% farming yield.',
      'level': 2,
      'maxLevel': 5,
      'icon': Icons.eco,
      'color': kRecColor,
      'upgradeCost': 600,
    },
    {
      'name': 'Alchemy Lab',
      'description': 'Create potions and elixirs. +12% alchemy success rate.',
      'level': 1,
      'maxLevel': 5,
      'icon': Icons.science,
      'color': kWisColor.withOpacity(0.7),
      'upgradeCost': 800,
    },
    {
      'name': 'Kitchen',
      'description': 'Cook meals with stat bonuses. +5% cooking efficiency.',
      'level': 0,
      'maxLevel': 5,
      'icon': Icons.restaurant,
      'color': kEndColor,
      'upgradeCost': 500,
    },
    {
      'name': 'Training Room',
      'description': 'Practice combat techniques. +3% STR and END gain.',
      'level': 0,
      'maxLevel': 5,
      'icon': Icons.sports_kabaddi,
      'color': kStrColor.withOpacity(0.7),
      'upgradeCost': 1000,
    },
  ];

  // Currently selected room
  Map<String, dynamic>? _selectedRoom;

  @override
  void initState() {
    super.initState();
    // Set a default selected room
    if (_rooms.isNotEmpty && _rooms[0]['level'] > 0) {
      _selectedRoom = _rooms[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final bool isPremium = user?.isPremium ?? false;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Gym Fortress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              _showThemeSelectDialog(context, isPremium);
            },
            tooltip: 'Change Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          // Fortress image/preview
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getThemeColor().withOpacity(0.2),
              image: DecorationImage(
                image: AssetImage('assets/images/fortress/$_currentTheme.png'),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) => {},
              ),
            ),
            child: Stack(
              children: [
                // Background shade for text visibility
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentTheme,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Level 5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: _getThemeColor().withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: _getThemeColor()),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Upgrade rooms in your fortress to gain passive bonuses and improve your skills.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Room list and selected room detail
          Expanded(
            child: Row(
              children: [
                // Room list sidebar
                Container(
                  width: 100,
                  color: Colors.grey.shade100,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      final isBuilt = room['level'] > 0;
                      final isSelected =
                          _selectedRoom != null && _selectedRoom == room;

                      return GestureDetector(
                        onTap:
                            isBuilt
                                ? () {
                                  setState(() {
                                    _selectedRoom = room;
                                  });
                                }
                                : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? room['color'].withOpacity(0.2)
                                    : null,
                            border:
                                isSelected
                                    ? Border(
                                      left: BorderSide(
                                        color: room['color'],
                                        width: 4,
                                      ),
                                    )
                                    : null,
                          ),
                          child: Opacity(
                            opacity: isBuilt ? 1.0 : 0.5,
                            child: Column(
                              children: [
                                Icon(
                                  room['icon'],
                                  color:
                                      isSelected
                                          ? room['color']
                                          : kLightTextColor,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  room['name'].split(
                                    ' ',
                                  )[0], // Just show first word to save space
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? room['color']
                                            : kLightTextColor,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (isBuilt)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: room['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Lvl ${room["level"]}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: room['color'],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Build',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Room details
                Expanded(
                  child:
                      _selectedRoom == null
                          ? _buildEmptyRoomView()
                          : _buildRoomDetailView(_selectedRoom!),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBuildRoomDialog(context);
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getThemeColor() {
    for (var theme in _themes) {
      if (theme['name'] == _currentTheme) {
        return theme['color'];
      }
    }
    return kPrimaryColor;
  }

  Widget _buildEmptyRoomView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 64, color: kLightTextColor),
          const SizedBox(height: 16),
          Text(
            'Select a Room',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a room from the sidebar to view details\nor upgrade it.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Build New Room',
            onPressed: () {
              _showBuildRoomDialog(context);
            },
            type: ButtonType.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailView(Map<String, dynamic> room) {
    final isMaxLevel = room['level'] == room['maxLevel'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: room['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(room['icon'], color: room['color'], size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room['name'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    Text(
                      'Level ${room["level"]}/${room["maxLevel"]}',
                      style: TextStyle(
                        fontSize: 16,
                        color: room['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Level Progress',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${room["level"]}/${room["maxLevel"]}',
                    style: TextStyle(color: kLightTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: room['level'] / room['maxLevel'],
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(room['color']),
                  minHeight: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(room['description'], style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),

          // Current bonuses
          const Text(
            'Current Bonuses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.add_circle, color: room['color'], size: 18),
              const SizedBox(width: 8),
              Text(
                room['description'].split('.')[0],
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Next level bonus (if not max level)
          if (!isMaxLevel) ...[
            const Text(
              'Next Level Bonus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.arrow_circle_up, color: room['color'], size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Increased bonus effects',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Upgrade button
            CustomButton(
              text: 'Upgrade (${room["upgradeCost"]} Gold)',
              onPressed: () {
                _showUpgradeConfirmationDialog(context, room);
              },
              isFullWidth: true,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This room is already at maximum level!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showThemeSelectDialog(BuildContext context, bool isPremium) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Fortress Theme',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 350,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: _themes.length,
                      itemBuilder: (context, index) {
                        final theme = _themes[index];
                        final bool isSelected = _currentTheme == theme['name'];
                        final bool isAvailable =
                            !theme['premiumRequired'] || isPremium;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                isSelected
                                    ? BorderSide(
                                      color: theme['color'],
                                      width: 2,
                                    )
                                    : BorderSide.none,
                          ),
                          child: InkWell(
                            onTap:
                                isAvailable
                                    ? () {
                                      setState(() {
                                        _currentTheme = theme['name'];
                                      });
                                      Navigator.of(ctx).pop();
                                    }
                                    : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: theme['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      theme['icon'],
                                      color: theme['color'],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              theme['name'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    isAvailable
                                                        ? kTextColor
                                                        : kLightTextColor,
                                              ),
                                            ),
                                            if (theme['premiumRequired']) ...[
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.star,
                                                color:
                                                    isPremium
                                                        ? Colors.amber
                                                        : Colors.grey,
                                                size: 16,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          theme['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                isAvailable
                                                    ? kLightTextColor
                                                    : Colors.grey,
                                          ),
                                        ),
                                        if (!isAvailable) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Premium Only',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: theme['color'],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showBuildRoomDialog(BuildContext context) {
    // Filter to only show rooms that aren't built yet
    final List<Map<String, dynamic>> unbuildRooms =
        _rooms.where((room) => room['level'] == 0).toList();

    if (unbuildRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All rooms have been built!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Build New Room',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: unbuildRooms.length,
                      itemBuilder: (context, index) {
                        final room = unbuildRooms[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(ctx).pop();
                              _showBuildConfirmationDialog(context, room);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: room['color'].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      room['icon'],
                                      color: room['color'],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: kTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          room['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: kLightTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.monetization_on,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${room["upgradeCost"]} gold',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showBuildConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> room,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Build ${room["name"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to build a ${room["name"]} for ${room["upgradeCost"]} gold?',
                ),
                const SizedBox(height: 16),
                Text(
                  room['description'],
                  style: TextStyle(fontSize: 14, color: kLightTextColor),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update room level
                  setState(() {
                    final index = _rooms.indexOf(room);
                    _rooms[index]['level'] = 1;
                    _selectedRoom = _rooms[index];
                  });
                  Navigator.of(ctx).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${room["name"]} has been built!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('BUILD'),
              ),
            ],
          ),
    );
  }

  void _showUpgradeConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> room,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Upgrade ${room["name"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to upgrade your ${room["name"]} to level ${room["level"] + 1} for ${room["upgradeCost"]} gold?',
                ),
                const SizedBox(height: 16),
                const Text(
                  'This will improve the room\'s bonuses.',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update room level
                  setState(() {
                    final index = _rooms.indexOf(room);
                    _rooms[index]['level']++;
                    _selectedRoom = _rooms[index];
                  });
                  Navigator.of(ctx).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${room["name"]} upgraded to level ${room["level"]}!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('UPGRADE'),
              ),
            ],
          ),
    );
  }
}
