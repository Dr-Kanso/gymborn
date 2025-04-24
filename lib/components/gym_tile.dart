import 'package:flutter/material.dart';
import '../services/gym_checkin_service.dart';
import '../themes/theme.dart';

class GymTile extends StatelessWidget {
  final Gym gym;
  final bool isSelected;
  final bool canCheckIn;
  final VoidCallback? onTap;
  final VoidCallback? onCheckIn;
  final VoidCallback? onRemove;
  final double? distance;

  const GymTile({
    super.key,
    required this.gym,
    this.isSelected = false,
    this.canCheckIn = false,
    this.onTap,
    this.onCheckIn,
    this.onRemove,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isSelected
                ? BorderSide(color: kPrimaryColor, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        gym.photoUrl != null && gym.photoUrl!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                gym.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.fitness_center,
                                    size: 28,
                                    color: kPrimaryColor,
                                  );
                                },
                              ),
                            )
                            : Icon(
                              Icons.fitness_center,
                              size: 28,
                              color: kPrimaryColor,
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gym.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gym.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: kLightTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (distance != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${distance!.toStringAsFixed(1)} km away',
                            style: TextStyle(
                              fontSize: 12,
                              color: kSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (canCheckIn) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('Check In'),
                        onPressed: onCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onRemove != null) ...[
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
