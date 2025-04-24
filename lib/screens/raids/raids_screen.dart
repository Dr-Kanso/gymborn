import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../themes/theme.dart';
import '../../models/role.dart';

class RaidsScreen extends StatefulWidget {
  const RaidsScreen({super.key});

  @override
  State<RaidsScreen> createState() => _RaidsScreenState();
}

class _RaidsScreenState extends State<RaidsScreen> {
  final List<Map<String, dynamic>> _availableRaids = [
    {
      'id': 'moonlight_gardens',
      'name': 'Moonlight Gardens',
      'level': 10,
      'description':
          'A mystical garden blooming under the moonlight, inhabited by forest spirits.',
      'players': '2-4',
      'rewards': ['Moonlight Essence', 'Verdant Seeds', 'Raid Card'],
      'color': kPrimaryColor,
      'requiredRoles': ['Vanguard', 'Windstrider', 'Mystic'],
      'image': 'assets/images/raids/moonlight_garden.jpg',
      'participants': [],
    },
    {
      'id': 'crystal_forge',
      'name': 'Crystal Forge',
      'level': 15,
      'description':
          'Ancient forge where magical weapons are crafted from crystalline materials.',
      'players': '3-5',
      'rewards': ['Forged Crystal', 'Enchanted Metal', 'Raid Card'],
      'color': kStrColor,
      'requiredRoles': ['Vanguard', 'Breaker', 'Architect', 'Sage'],
      'image': 'assets/images/raids/crystal_forge.jpg',
      'participants': [
        {'name': 'MysticWarrior', 'role': 'Vanguard', 'level': 25},
        {'name': 'CrystalSeeker', 'role': 'Architect', 'level': 22},
      ],
    },
    {
      'id': 'celestial_observatory',
      'name': 'Celestial Observatory',
      'level': 20,
      'description':
          'An ancient stargazing tower where cosmic energy flows freely.',
      'players': '3-5',
      'rewards': ['Celestial Fragment', 'Cosmic Dust', 'Raid Card'],
      'color': kWisColor,
      'requiredRoles': ['Mystic', 'Sage', 'Windstrider', 'Vanguard'],
      'image': 'assets/images/raids/celestial_observatory.jpg',
      'participants': [],
    },
  ];

  Map<String, dynamic>? _selectedRaid;
  RoleType? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user!;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text('Raids')),
      body:
          _selectedRaid == null
              ? _buildRaidsList(user)
              : _buildRaidDetailView(user),
    );
  }

  Widget _buildRaidsList(user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: kPrimaryColor.withAlpha((0.1 * 255).round()),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Join raids with other players to earn special rewards. Each raid requires specific roles.',
                  style: TextStyle(color: kTextColor, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _availableRaids.length,
            itemBuilder: (context, index) {
              final raid = _availableRaids[index];
              return _buildRaidCard(raid, user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRaidCard(Map<String, dynamic> raid, user) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRaid = raid;
            _selectedRole = null;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Raid image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: raid['color'].withAlpha((0.2 * 255).round()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(Icons.panorama, size: 48, color: raid['color']),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        raid['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: raid['color'].withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Level ${raid["level"]}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: raid['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    raid['description'],
                    style: TextStyle(fontSize: 14, color: kTextColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Participants
                  Row(
                    children: [
                      Icon(Icons.group, size: 16, color: kLightTextColor),
                      const SizedBox(width: 4),
                      Text(
                        '${raid['participants'].length} / ${raid['players'].split('-')[1]} players',
                        style: TextStyle(fontSize: 14, color: kLightTextColor),
                      ),
                      const Spacer(),
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: raid['color'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: raid['color'], size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaidDetailView(user) {
    final raid = _selectedRaid!;
    final availableRoles = user.availableRoles;
    final possibleRoles =
        raid['requiredRoles']
            .where((role) => availableRoles.contains(role))
            .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Raid image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: raid['color'].withAlpha((0.2 * 255).round()),
            ),
            child: Center(
              child: Icon(Icons.panorama, size: 72, color: raid['color']),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRaid = null;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: kLightTextColor),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Raids',
                        style: TextStyle(color: kLightTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Raid name and level
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        raid['name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTextColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: raid['color'].withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${raid["level"]}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: raid['color'],
                        ),
                      ),
                    ),
                  ],
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
                  raid['description'],
                  style: TextStyle(fontSize: 16, color: kTextColor),
                ),
                const SizedBox(height: 16),

                // Required roles
                Text(
                  'Required Roles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      raid['requiredRoles'].map<Widget>((role) {
                        final bool isAvailable = availableRoles.contains(role);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isAvailable
                                    ? raid['color'].withAlpha(
                                      (0.2 * 255).round(),
                                    )
                                    : Colors.grey.withAlpha(
                                      (0.2 * 255).round(),
                                    ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAvailable ? raid['color'] : Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              color: isAvailable ? raid['color'] : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      raid['rewards'].map<Widget>((reward) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.1 * 255).round(),
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            reward,
                            style: TextStyle(color: kTextColor),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),

                // Current participants
                Text(
                  'Current Participants (${raid['participants'].length}/${raid['players'].split('-')[1]})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                raid['participants'].isEmpty
                    ? Text(
                      'No participants yet. Be the first to join!',
                      style: TextStyle(
                        color: kLightTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                    : Column(
                      children:
                          raid['participants'].map<Widget>((participant) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: raid['color'].withAlpha(
                                  (0.2 * 255).round(),
                                ),
                                child: const Icon(Icons.person),
                              ),
                              title: Text(participant['name']),
                              subtitle: Text(
                                '${participant['role']} (Level ${participant['level']})',
                              ),
                            );
                          }).toList(),
                    ),
                const SizedBox(height: 24),

                // Join raid section
                if (possibleRoles.isNotEmpty)
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
                            'Join Raid',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select your role:',
                            style: TextStyle(fontSize: 16, color: kTextColor),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                possibleRoles.map<Widget>((role) {
                                  final RoleType? roleType =
                                      _getRoleTypeFromString(role);
                                  return ChoiceChip(
                                    label: Text(role),
                                    selected: _selectedRole == roleType,
                                    onSelected: (_) {
                                      setState(() {
                                        _selectedRole = roleType;
                                      });
                                    },
                                    selectedColor: raid['color'].withAlpha(
                                      // Updated
                                      (0.2 * 255).round(),
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Join Raid',
                            isFullWidth: true,
                            onPressed: () {
                              if (_selectedRole != null) {
                                _showRaidJoinPlaceholder();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
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
                            'Cannot Join Raid',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You don\'t have any of the required roles for this raid. '
                            'Continue training to unlock more roles!',
                            style: TextStyle(color: kLightTextColor),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Train Stats',
                            isFullWidth: true,
                            onPressed: () {
                              Navigator.pushNamed(context, '/stats');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRaidJoinPlaceholder() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Raid Joining'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This feature will be implemented with the Flame game engine. '
                  'For now, this is a placeholder.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  RoleType? _getRoleTypeFromString(String roleStr) {
    switch (roleStr) {
      case 'Vanguard':
        return RoleType.vanguard;
      case 'Breaker':
        return RoleType.breaker;
      case 'Windstrider':
        return RoleType.windstrider;
      case 'Mystic':
        return RoleType.mystic;
      case 'Sage':
        return RoleType.sage;
      case 'Architect':
        return RoleType.architect;
      case 'Verdant':
        return RoleType.verdant;
      default:
        return null;
    }
  }
}
