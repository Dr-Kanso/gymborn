import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../themes/theme.dart';
import '../../config/constants.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _marketItems = [
    {
      'id': '1',
      'name': 'Strength Crystal',
      'type': 'Material',
      'description':
          'A brilliant crystal pulsing with strength energy. Used in crafting weapons.',
      'price': 500,
      'seller': 'CrystalMaster',
      'image': 'assets/images/marketplace/strength_crystal.png',
      'color': kStrColor,
    },
    {
      'id': '2',
      'name': 'Verdant Potion',
      'type': 'Consumable',
      'description': 'Restores 50 health and provides +5 REC for 1 hour.',
      'price': 350,
      'seller': 'AlchemyWizard',
      'image': 'assets/images/marketplace/verdant_potion.png',
      'color': kRecColor,
    },
    {
      'id': '3',
      'name': 'Moonlight Shield',
      'type': 'Equipment',
      'description':
          'A shield crafted from celestial metals. +20 Defense, +5 WIS.',
      'price': 1200,
      'seller': 'StarForger',
      'image': 'assets/images/marketplace/moonlight_shield.png',
      'color': kWisColor,
    },
    {
      'id': '4',
      'name': 'Swift Runner\'s Boots',
      'type': 'Equipment',
      'description':
          'Enchanted boots that increase movement speed. +15 END, +10 Movement Speed.',
      'price': 950,
      'seller': 'WindWalker',
      'image': 'assets/images/marketplace/swift_boots.png',
      'color': kEndColor,
    },
    {
      'id': '5',
      'name': 'Cosmic Insight Card',
      'type': 'Card',
      'description': 'Synergy card that increases WIS gain by 10%.',
      'price': 2000,
      'seller': 'CardCollector',
      'image': 'assets/images/marketplace/cosmic_card.png',
      'color': kWisColor,
    },
  ];

  // Implement user listings data fetching and display
  // final List<Map<String, dynamic>> _userListings = [
  //   // This would be populated from user data
  // ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final bool isPremium = user?.isPremium ?? false;

    final double marketplaceTax =
        isPremium
            ? GymConstants.premiumMarketplaceTax
            : GymConstants.freeMarketplaceTax;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kLightTextColor,
          indicatorColor: kPrimaryColor,
          tabs: const [
            Tab(text: 'Browse'),
            Tab(text: 'Your Listings'),
            Tab(text: 'Purchases'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: kPrimaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: kPrimaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Marketplace tax: ${(marketplaceTax * 100).toInt()}% ${isPremium ? "(Premium)" : ""}',
                    style: TextStyle(color: kTextColor, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search marketplace',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBrowseTab(),
                _buildListingsTab(),
                _buildPurchasesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateListingDialog(context);
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBrowseTab() {
    // Filter items based on search query
    final filteredItems =
        _searchQuery.isEmpty
            ? _marketItems
            : _marketItems
                .where(
                  (item) =>
                      item['name'].toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      item['type'].toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      item['description'].toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList();

    return filteredItems.isEmpty
        ? Center(
          child: Text(
            'No items found matching "$_searchQuery"',
            style: TextStyle(color: kLightTextColor),
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return _buildMarketItemCard(item);
          },
        );
  }

  Widget _buildListingsTab() {
    // This would be populated from user data
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 64, color: kLightTextColor),
          const SizedBox(height: 16),
          Text(
            'You don\'t have any active listings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create new listings by tapping the + button',
            style: TextStyle(color: kLightTextColor),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Listing',
            onPressed: () {
              _showCreateListingDialog(context);
            },
            type: ButtonType.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesTab() {
    // This would show purchase history
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: kLightTextColor),
          const SizedBox(height: 16),
          Text(
            'No Purchase History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your purchase history will appear here',
            style: TextStyle(color: kLightTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showItemDetailDialog(context, item);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(item['type']),
                  color: item['color'] as Color,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                    Text(
                      item['type'],
                      style: TextStyle(
                        fontSize: 14,
                        color: item['color'] as Color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: TextStyle(fontSize: 14, color: kLightTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item['price']} gold',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kTextColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Seller: ${item['seller']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: kLightTextColor,
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
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Material':
        return Icons.diamond;
      case 'Consumable':
        return Icons.local_drink;
      case 'Equipment':
        return Icons.shield;
      case 'Card':
        return Icons.style;
      default:
        return Icons.inventory_2;
    }
  }

  void _showItemDetailDialog(BuildContext context, Map<String, dynamic> item) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final bool isPremium = user?.isPremium ?? false;

    final double marketplaceTax =
        isPremium
            ? GymConstants.premiumMarketplaceTax
            : GymConstants.freeMarketplaceTax;

    final int taxAmount = (item['price'] * marketplaceTax).round();
    final int totalPrice = item['price'] + taxAmount;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(item['name']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item image
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getIconForType(item['type']),
                      color: item['color'] as Color,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Item details
                Text(
                  'Type: ${item["type"]}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(item['description'], style: TextStyle(fontSize: 14)),
                const SizedBox(height: 16),

                // Price details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Base Price:', style: TextStyle(fontSize: 14)),
                    Text(
                      '${item["price"]} gold',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Marketplace Tax:', style: TextStyle(fontSize: 14)),
                    Text(
                      '$taxAmount gold (${(marketplaceTax * 100).toInt()}%)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalPrice gold',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Seller: ${item["seller"]}',
                  style: TextStyle(fontSize: 14, color: kLightTextColor),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CLOSE'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Show purchase confirmation dialog
                  _showPurchaseConfirmationDialog(context, item, totalPrice);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: const Text('BUY'),
              ),
            ],
          ),
    );
  }

  void _showPurchaseConfirmationDialog(
    BuildContext context,
    Map<String, dynamic> item,
    int totalPrice,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Purchase'),
            content: Text(
              'Are you sure you want to purchase ${item["name"]} for $totalPrice gold?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // Show purchase success dialog
                  _showPurchaseSuccessDialog(context, item);
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
    );
  }

  void _showPurchaseSuccessDialog(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Purchase Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  'You have successfully purchased ${item["name"]}.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'The item has been added to your inventory.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showCreateListingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Create Listing'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This feature will be implemented in the future. For now, this is a placeholder.',
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
}
