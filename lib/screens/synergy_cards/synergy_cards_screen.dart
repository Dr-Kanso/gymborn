import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../themes/theme.dart';
import '../../models/card.dart';
import '../../config/constants.dart';

class SynergyCardsScreen extends StatefulWidget {
  const SynergyCardsScreen({super.key});

  @override
  State<SynergyCardsScreen> createState() => _SynergyCardsScreenState();
}

class _SynergyCardsScreenState extends State<SynergyCardsScreen> {
  // Sample cards for demonstration
  final List<SynergyCard> _userCards = [
    SynergyCard(
      id: '1',
      name: 'Iron Will',
      description: 'Increases STR gain by 10% when working out.',
      imageUrl: '',
      rarity: CardRarity.rare,
      effects: {
        'stat_boost': {'type': 'STR', 'value': 0.10},
      },
      source: 'Iron Temple',
    ),
    SynergyCard(
      id: '2',
      name: 'Swift Runner',
      description: 'Increases END gain by 8% when running or cycling.',
      imageUrl: '',
      rarity: CardRarity.uncommon,
      effects: {
        'stat_boost': {'type': 'END', 'value': 0.08},
      },
      source: 'Endless Paths',
    ),
    SynergyCard(
      id: '3',
      name: 'Moonlit Meditation',
      description: 'Increases WIS gain by 12% when meditating.',
      imageUrl: '',
      rarity: CardRarity.epic,
      effects: {
        'stat_boost': {'type': 'WIS', 'value': 0.12},
      },
      source: 'Mystic Meditation Cave',
    ),
  ];

  // Currently equipped cards (indices from _userCards)
  final List<int> _equippedCardIndices = [0, 1];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final bool isPremium = user?.isPremium ?? false;

    final int maxCardSlots =
        isPremium ? GymConstants.premiumCardSlots : GymConstants.freeCardSlots;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text('Synergy Cards')),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: kPrimaryColor.withAlpha((0.1 * 255).round()),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: kPrimaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cards provide passive bonuses. You can equip up to $maxCardSlots cards at once ${isPremium ? "(Premium)" : ""}',
                    style: TextStyle(color: kTextColor, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Equipped cards section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equipped Cards (${_equippedCardIndices.length}/$maxCardSlots)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child:
                      _equippedCardIndices.isEmpty
                          ? Center(
                            child: Text(
                              'No cards equipped',
                              style: TextStyle(color: kLightTextColor),
                            ),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(16),
                            itemCount: _equippedCardIndices.length,
                            itemBuilder: (context, index) {
                              final card =
                                  _userCards[_equippedCardIndices[index]];
                              return _buildCardItem(
                                card,
                                isEquipped: true,
                                index: _equippedCardIndices[index],
                              );
                            },
                          ),
                ),
              ],
            ),
          ),

          // All cards section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Cards (${_userCards.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _userCards.length,
                      itemBuilder: (context, index) {
                        final card = _userCards[index];
                        final bool isEquipped = _equippedCardIndices.contains(
                          index,
                        );

                        return _buildCardItem(
                          card,
                          isEquipped: isEquipped,
                          index: index,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    SynergyCard card, {
    required bool isEquipped,
    required int index,
  }) {
    final Color cardColor = SynergyCard.getRarityColor(card.rarity);

    return GestureDetector(
      onTap: () {
        _showCardDetailDialog(context, card, isEquipped, index);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cardColor.withAlpha((0.7 * 255).round()),
              cardColor.withAlpha((0.9 * 255).round()),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cardColor.withAlpha((0.3 * 255).round()),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: isEquipped ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card name
                  Text(
                    card.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Card rarity
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getRarityString(card.rarity),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Card effect icon
                  Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        _getEffectIcon(card.effects),
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Card description
                  Text(
                    card.description,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Equipped indicator
            if (isEquipped)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Icon(Icons.check, color: cardColor, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRarityString(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return 'Common';
      case CardRarity.uncommon:
        return 'Uncommon';
      case CardRarity.rare:
        return 'Rare';
      case CardRarity.epic:
        return 'Epic';
      case CardRarity.legendary:
        return 'Legendary';
    }
  }

  IconData _getEffectIcon(Map<String, dynamic> effects) {
    if (effects.containsKey('stat_boost')) {
      final statType = effects['stat_boost']['type'];
      switch (statType) {
        case 'STR':
          return Icons.fitness_center;
        case 'END':
          return Icons.directions_run;
        case 'WIS':
          return Icons.self_improvement;
        case 'REC':
          return Icons.bedtime;
        default:
          return Icons.star;
      }
    }
    return Icons.star;
  }

  void _showCardDetailDialog(
    BuildContext context,
    SynergyCard card,
    bool isEquipped,
    int cardIndex,
  ) {
    final Color cardColor = SynergyCard.getRarityColor(card.rarity);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(card.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card rarity and source
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getRarityString(card.rarity),
                        style: TextStyle(
                          color: cardColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Source: ${card.source}',
                      style: TextStyle(color: kLightTextColor, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card description
                Text(card.description, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                // Card effects
                Text(
                  'Effects:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (card.effects.containsKey('stat_boost'))
                  Row(
                    children: [
                      Icon(_getEffectIcon(card.effects), color: cardColor),
                      const SizedBox(width: 8),
                      Text(
                        '+${(card.effects['stat_boost']['value'] * 100).toInt()}% ${card.effects['stat_boost']['type']} gain',
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CLOSE'),
              ),
              isEquipped
                  ? TextButton(
                    onPressed: () {
                      setState(() {
                        _equippedCardIndices.remove(cardIndex);
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('UNEQUIP'),
                  )
                  : TextButton(
                    onPressed: () {
                      // Check if we can equip more cards
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final user = authProvider.user;
                      final bool isPremium = user?.isPremium ?? false;
                      final int maxCardSlots =
                          isPremium
                              ? GymConstants.premiumCardSlots
                              : GymConstants.freeCardSlots;

                      if (_equippedCardIndices.length < maxCardSlots) {
                        setState(() {
                          _equippedCardIndices.add(cardIndex);
                        });
                        Navigator.of(ctx).pop();
                      } else {
                        // Show error that max cards are equipped
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You can only equip $maxCardSlots cards at once. Unequip a card first.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('EQUIP'),
                  ),
            ],
          ),
    );
  }
}
