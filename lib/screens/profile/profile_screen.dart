import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../themes/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _displayNameController = TextEditingController(
      text: authProvider.user?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
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
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Cancel editing
                  _displayNameController.text = user.displayName;
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: kPrimaryColor.withOpacity(0.2),
                    child:
                        user.photoUrl.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                user.photoUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: kPrimaryColor,
                                    ),
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              size: 60,
                              color: kPrimaryColor,
                            ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a display name';
                            }
                            return null;
                          },
                        ),
                      ),
                    )
                  else
                    Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kTextColor,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email, size: 16, color: kLightTextColor),
                      const SizedBox(width: 8),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: kLightTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getTrustLevelColor(
                        user.trustLevel,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTrustLevelIcon(user.trustLevel),
                          size: 16,
                          color: _getTrustLevelColor(user.trustLevel),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.trustLevel,
                          style: TextStyle(
                            color: _getTrustLevelColor(user.trustLevel),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: CustomButton(
                        text: 'Save Changes',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await authProvider.updateProfile(
                              displayName: _displayNameController.text,
                            );

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                ),
                              );
                              setState(() {
                                _isEditing = false;
                              });
                            }
                          }
                        },
                        isLoading: authProvider.isLoading,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Account section
            Text(
              'Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileCard(
              title: 'Account Type',
              value: user.isPremium ? 'Premium Member' : 'Free Account',
              icon: user.isPremium ? Icons.star : Icons.person_outline,
              color: user.isPremium ? Colors.amber : kLightTextColor,
            ),

            _buildProfileCard(
              title: 'Roles Available',
              value:
                  user.availableRoles.isEmpty
                      ? 'None yet'
                      : user.availableRoles.join(', '),
              icon: Icons.style,
              color: kPrimaryColor,
            ),

            _buildProfileCard(
              title: 'Gyms Registered',
              value: '${user.gymIds.length} gym(s)',
              icon: Icons.fitness_center,
              color: kStrColor,
            ),

            const SizedBox(height: 32),

            // Membership section for free users
            if (!user.isPremium)
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
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade to Premium',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumFeatureRow(
                        'Extra Card Slot (4 instead of 3)',
                      ),
                      _buildPremiumFeatureRow(
                        'Reduced Marketplace Tax (3% instead of 10%)',
                      ),
                      _buildPremiumFeatureRow(
                        'Extra Gym Slots (10 instead of 5)',
                      ),
                      _buildPremiumFeatureRow('Exclusive Fortress Themes'),
                      _buildPremiumFeatureRow('Idle Boost & Cosmetic Auras'),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Upgrade for \$7.99/month',
                        onPressed: () {
                          _showPremiumUpgradeDialog();
                        },
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Sign out button
            CustomButton(
              text: 'Sign Out',
              onPressed: () async {
                await authProvider.signOut();
              },
              type: ButtonType.outline,
              isFullWidth: true,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: kLightTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kSecondaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(fontSize: 14, color: kTextColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumUpgradeDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Premium Membership'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This feature will be implemented with in-app purchases. For now, this is a placeholder.',
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

  IconData _getTrustLevelIcon(String trustLevel) {
    switch (trustLevel) {
      case 'Verified':
        return Icons.verified;
      case 'Standard':
        return Icons.check_circle;
      case 'Flagged':
        return Icons.warning_amber;
      default:
        return Icons.info;
    }
  }

  Color _getTrustLevelColor(String trustLevel) {
    switch (trustLevel) {
      case 'Verified':
        return Colors.green;
      case 'Standard':
        return kPrimaryColor;
      case 'Flagged':
        return Colors.red;
      default:
        return kLightTextColor;
    }
  }
}
