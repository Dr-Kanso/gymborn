import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/gym_provider.dart';
import '../../themes/theme.dart';
import '../../components/custom_button.dart';

// Convert to StatefulWidget to properly handle BuildContext in async operations
class GymCheckinScreen extends StatefulWidget {
  const GymCheckinScreen({super.key});

  @override
  State<GymCheckinScreen> createState() => _GymCheckinScreenState();
}

class _GymCheckinScreenState extends State<GymCheckinScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gymProvider = Provider.of<GymProvider>(context);

    final user = authProvider.user!;
    // Use nearbyGyms instead of gyms to match existing GymProvider implementation
    final gyms = gymProvider.nearbyGyms;

    return Scaffold(
      appBar: AppBar(title: const Text('Gym Check-in')),
      body:
          gyms.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: gyms.length,
                itemBuilder: (context, index) {
                  final gym = gyms[index];
                  final canCheckIn = gymProvider.canCheckInToday(
                    user.uid,
                    gym.id,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gym.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(gym.address),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                canCheckIn
                                    ? 'Available now'
                                    : 'Next available in: ${gymProvider.getTimeUntilNextCheckin(gym.id)}',
                                style: TextStyle(
                                  color:
                                      canCheckIn
                                          ? Colors.green
                                          : kLightTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text:
                                canCheckIn
                                    ? 'Check In'
                                    : 'Already Checked In Today',
                            // Fix: Convert null to empty function for the onPressed parameter
                            onPressed:
                                canCheckIn
                                    ? () => _handleCheckIn(
                                      context,
                                      gymProvider,
                                      user.uid,
                                      gym.id,
                                    )
                                    : () {}, // Empty function instead of null
                            // Fix: Using secondary instead of disabled (assuming this exists)
                            type:
                                canCheckIn
                                    ? ButtonType.primary
                                    : ButtonType.secondary,
                            isFullWidth: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Future<void> _handleCheckIn(
    BuildContext context,
    GymProvider gymProvider,
    String userId,
    String gymId,
  ) async {
    // Show loading indicator - context usage here is fine as it's before the first await
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Check in logic (validate location, etc.)
      // ... existing location validation code ...

      // Record the check-in
      final success = await gymProvider.checkIn(userId, gymId);

      // Guard context usage after await
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Show success message
        // Guard context usage after await
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully checked in!'),
            backgroundColor: Colors.green,
          ),
        );

        // Provide rewards here
        // ... existing reward code ...
      }
    } catch (e) {
      // Guard context usage after await
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking in: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
