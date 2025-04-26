import 'package:flutter/material.dart';
import '../../components/custom_button.dart';
import '../../themes/theme.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final Map<String, Map<String, dynamic>> _skillsInfo = {
    'Smithing': {
      'description': 'Craft weapons and armor using ore and other materials.',
      'icon': Icons.build,
      'color': kStrColor,
      'level': 5,
      'maxLevel': 100,
      'recipes': [
        {
          'name': 'Iron Sword',
          'level': 10,
          'materials': ['Iron Ore x5', 'Wood x2'],
        },
        {
          'name': 'Steel Shield',
          'level': 20,
          'materials': ['Steel Ingot x3', 'Leather x2'],
        },
      ],
    },
    'Alchemy': {
      'description': 'Create potions and elixirs from herbs and essences.',
      'icon': Icons.science,
      'color': kWisColor,
      'level': 8,
      'maxLevel': 100,
      'recipes': [
        {
          'name': 'Minor Health Potion',
          'level': 5,
          'materials': ['Red Herb x2', 'Water x1'],
        },
        {
          'name': 'Strength Elixir',
          'level': 15,
          'materials': ['Power Root x3', 'Crystal Water x1'],
        },
      ],
    },
    'Farming': {
      'description':
          'Grow herbs and harvest resources for cooking and alchemy.',
      'icon': Icons.eco,
      'color': kRecColor,
      'level': 12,
      'maxLevel': 100,
      'recipes': [
        {
          'name': 'Red Herb',
          'level': 1,
          'materials': ['Seed x1', 'Water x1'],
        },
        {
          'name': 'Power Root',
          'level': 10,
          'materials': ['Special Seed x1', 'Fertilizer x1'],
        },
      ],
    },
    'Runescribing': {
      'description': 'Create magical runes to enhance equipment and abilities.',
      'icon': Icons.auto_fix_high,
      'color': kWisColor.withAlpha((0.7 * 255).round()), // Updated
      'level': 3,
      'maxLevel': 100,
      'recipes': [
        {
          'name': 'Minor Strength Rune',
          'level': 10,
          'materials': ['Blank Rune x1', 'Red Essence x2'],
        },
        {
          'name': 'Endurance Rune',
          'level': 20,
          'materials': ['Quality Rune x1', 'Blue Essence x3'],
        },
      ],
    },
    'Cooking': {
      'description': 'Prepare meals that provide temporary stat boosts.',
      'icon': Icons.restaurant,
      'color': kEndColor,
      'level': 7,
      'maxLevel': 100,
      'recipes': [
        {
          'name': 'Energy Bar',
          'level': 5,
          'materials': ['Grain x2', 'Fruit x1'],
        },
        {
          'name': 'Recovery Soup',
          'level': 15,
          'materials': ['Vegetables x3', 'Herbs x2', 'Water x1'],
        },
      ],
    },
    'Construction': {
      'description': 'Build and upgrade rooms in your Gym Fortress.',
      'icon': Icons.home,
      'color': kPrimaryColor,
      'level': 4,
      'maxLevel': 100,
      'recipes': [
        {
          'name': 'Basic Storage Room',
          'level': 10,
          'materials': ['Wood x10', 'Stone x5'],
        },
        {
          'name': 'Simple Crafting Station',
          'level': 20,
          'materials': ['Wood x15', 'Iron x8', 'Crystal x3'],
        },
      ],
    },
  };

  String? _selectedSkill;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text('Skills')),
      body: Row(
        children: [
          // Skills sidebar
          Container(
            width: 100,
            color: Colors.grey.shade100,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children:
                  _skillsInfo.keys.map((skillName) {
                    final skill = _skillsInfo[skillName]!;
                    final bool isSelected = _selectedSkill == skillName;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSkill = skillName;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? skill['color'].withAlpha(
                                    (0.2 * 255).round(),
                                  ) // Updated
                                  : null,
                          border:
                              isSelected
                                  ? Border(
                                    left: BorderSide(
                                      color: skill['color'],
                                      width: 4,
                                    ),
                                  )
                                  : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              skill['icon'],
                              color:
                                  isSelected ? skill['color'] : kLightTextColor,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skillName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? skill['color']
                                        : kLightTextColor,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lvl ${skill["level"]}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? skill['color']
                                        : kLightTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Skill details
          Expanded(
            child:
                _selectedSkill == null
                    ? _buildSkillsOverview()
                    : _buildSkillDetails(_selectedSkill!),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsOverview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a skill from the sidebar to view details and recipes.',
            style: TextStyle(color: kLightTextColor),
          ),
          const SizedBox(height: 24),

          // Skills summary
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _skillsInfo.length,
              itemBuilder: (context, index) {
                final skillName = _skillsInfo.keys.elementAt(index);
                final skill = _skillsInfo[skillName]!;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSkill = skillName;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(skill['icon'], color: skill['color'], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            skillName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level: ${skill["level"]}/${skill["maxLevel"]}',
                            style: TextStyle(color: kLightTextColor),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: skill['level'] / skill['maxLevel'],
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                skill['color'],
                              ),
                              minHeight: 8,
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
    );
  }

  Widget _buildSkillDetails(String skillName) {
    final skill = _skillsInfo[skillName]!;
    final recipes = skill['recipes'] as List<Map<String, dynamic>>;
    final List<Map<String, dynamic>> availableRecipes = [];
    final List<Map<String, dynamic>> lockedRecipes = [];

    // Separate available and locked recipes
    for (var recipe in recipes) {
      if (recipe['level'] <= skill['level']) {
        availableRecipes.add(recipe);
      } else {
        lockedRecipes.add(recipe);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skill header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: skill['color'].withAlpha(
                    (0.2 * 255).round(),
                  ), // Updated
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(skill['icon'], color: skill['color'], size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skillName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    Text(
                      'Level ${skill["level"]}/${skill["maxLevel"]}',
                      style: TextStyle(
                        fontSize: 16,
                        color: skill['color'],
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
                  Text(
                    'Progress',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${skill["level"]}/${skill["maxLevel"]}',
                    style: TextStyle(color: kLightTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: skill['level'] / skill['maxLevel'],
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(skill['color']),
                  minHeight: 12,
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
            skill['description'],
            style: TextStyle(fontSize: 16, color: kTextColor),
          ),
          const SizedBox(height: 24),

          // Recipes section
          Text(
            'Available Recipes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 12),

          // Available recipes
          availableRecipes.isEmpty
              ? Text(
                'No recipes available yet. Keep leveling up!',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: kLightTextColor,
                ),
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: availableRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = availableRecipes[index];
                    return _buildRecipeItem(recipe, skill['color']);
                  },
                ),
              ),

          // Locked recipes
          if (lockedRecipes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Locked Recipes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: lockedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = lockedRecipes[index];
                  return _buildRecipeItem(recipe, skill['color'], locked: true);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeItem(
    Map<String, dynamic> recipe,
    Color skillColor, {
    bool locked = false,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: locked ? Colors.grey.shade100 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        locked
                            ? Colors.grey.withAlpha(
                              (0.2 * 255).round(),
                            ) // Updated
                            : skillColor.withAlpha(
                              (0.2 * 255).round(),
                            ), // Updated
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    locked ? Icons.lock : Icons.check_circle,
                    color: locked ? Colors.grey : skillColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recipe['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: locked ? kLightTextColor : kTextColor,
                    ),
                  ),
                ),
                if (locked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(
                        (0.2 * 255).round(),
                      ), // Updated
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Level ${recipe["level"]}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Materials:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: locked ? kLightTextColor : kTextColor,
              ),
            ),
            const SizedBox(height: 4),
            ...List.generate(recipe['materials'].length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${recipe['materials'][index]}',
                  style: TextStyle(
                    fontSize: 14,
                    color: locked ? kLightTextColor : kTextColor,
                  ),
                ),
              );
            }),
            if (!locked) ...[
              const SizedBox(height: 12),
              CustomButton(
                text: 'Craft',
                onPressed: () {
                  // Implement crafting logic
                  _showCraftingDialog(recipe);
                },
                type: ButtonType.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCraftingDialog(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Craft ${recipe["name"]}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This crafting feature will be implemented in a future update.',
                ),
                const SizedBox(height: 16),
                const Text('Materials required:'),
                const SizedBox(height: 8),
                ...List.generate(recipe['materials'].length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(recipe['materials'][index]),
                      ],
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CRAFT'),
              ),
            ],
          ),
    );
  }
}
