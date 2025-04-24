import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/gym_provider.dart';
import '../../themes/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _initProviders();
      _isInit = true;
    }
  }

  Future<void> _initProviders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final statsProvider = Provider.of<StatsProvider>(context, listen: false);
    final gymProvider = Provider.of<GymProvider>(context, listen: false);

    if (authProvider.user != null) {
      statsProvider.initStats(authProvider.user!);
      await gymProvider.initGyms(authProvider.user!);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('Welcome, ${user.displayName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          _buildStatsTab(),
          _buildDungeonsTab(),
          _buildMoreTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Stats',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Dungeons'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kLightTextColor,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildHomeTab() {
    final statsProvider = Provider.of<StatsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final stats = statsProvider.stats;

    if (stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kPrimaryColor,
                    kPrimaryColor.withAlpha((0.7 * 255).round()),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Total Level: ${stats.totalLevel}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatIndicator('STR', stats.strength, kStrColor),
                      _buildStatIndicator('END', stats.endurance, kEndColor),
                      _buildStatIndicator('WIS', stats.wisdom, kWisColor),
                      _buildStatIndicator('REC', stats.recovery, kRecColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // View all
                },
                child: Text('View All', style: TextStyle(color: kPrimaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.location_on,
                  title: 'Check In',
                  subtitle: 'Enter the Gym',
                  color: kStrColor,
                  onTap: () => Navigator.pushNamed(context, '/gym-checkin'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.add_chart,
                  title: 'Log Workout',
                  subtitle: 'Gain Stats',
                  color: kEndColor,
                  onTap: () => Navigator.pushNamed(context, '/stats'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.explore,
                  title: 'Dungeon',
                  subtitle: 'Daily Challenge',
                  color: kWisColor,
                  onTap: () => Navigator.pushNamed(context, '/dungeon'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.home,
                  title: 'Fortress',
                  subtitle: 'Your Base',
                  color: kRecColor,
                  onTap: () => Navigator.pushNamed(context, '/gym-fortress'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: kStrColor.withAlpha((0.2 * 255).round()),
                child: Icon(Icons.fitness_center, color: kStrColor),
              ),
              title: Text('Strength Workout'),
              subtitle: Text('Gained +3 STR'),
              trailing: Text('Today', style: TextStyle(color: kLightTextColor)),
            ),
          ),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: kEndColor.withAlpha((0.2 * 255).round()),
                child: Icon(Icons.directions_run, color: kEndColor),
              ),
              title: Text('Cardio Session'),
              subtitle: Text('Gained +2 END'),
              trailing: Text(
                'Yesterday',
                style: TextStyle(color: kLightTextColor),
              ),
            ),
          ),
          if (!authProvider.user!.isPremium) ...[
            const SizedBox(height: 24),
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
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get extra card slots, reduced marketplace fees, extra gym slots and more!',
                      style: TextStyle(color: kLightTextColor),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Upgrade Now',
                      onPressed: () {
                        // Premium upgrade flow
                      },
                      type: ButtonType.secondary,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatIndicator(String name, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildStatsTab() {
    return Center(
      child: TextButton(
        child: const Text('Go to Stats Screen'),
        onPressed: () {
          Navigator.pushNamed(context, '/stats');
        },
      ),
    );
  }

  Widget _buildDungeonsTab() {
    return Center(
      child: TextButton(
        child: const Text('Go to Dungeons Screen'),
        onPressed: () {
          Navigator.pushNamed(context, '/dungeon');
        },
      ),
    );
  }

  Widget _buildMoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            title: 'Raids',
            icon: Icons.groups,
            color: kStrColor,
            onTap: () => Navigator.pushNamed(context, '/raids'),
          ),
          _buildMenuTile(
            title: 'Marketplace',
            icon: Icons.store,
            color: kEndColor,
            onTap: () => Navigator.pushNamed(context, '/marketplace'),
          ),
          _buildMenuTile(
            title: 'Synergy Cards',
            icon: Icons.style,
            color: kWisColor,
            onTap: () => Navigator.pushNamed(context, '/synergy-cards'),
          ),
          _buildMenuTile(
            title: 'Skills',
            icon: Icons.construction,
            color: kRecColor,
            onTap: () => Navigator.pushNamed(context, '/skills'),
          ),
          _buildMenuTile(
            title: 'Gym Fortress',
            icon: Icons.home,
            color: kPrimaryColor,
            onTap: () => Navigator.pushNamed(context, '/gym-fortress'),
          ),
          const SizedBox(height: 24),
          Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            title: 'Profile',
            icon: Icons.person,
            color: Colors.blueGrey,
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          _buildMenuTile(
            title: 'Settings',
            icon: Icons.settings,
            color: Colors.grey,
            onTap: () {
              // Navigate to settings
            },
          ),
          _buildMenuTile(
            title: 'Sign Out',
            icon: Icons.logout,
            color: Colors.red,
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(Icons.chevron_right, color: kLightTextColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
