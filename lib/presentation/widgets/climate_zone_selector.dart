import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../providers/providers.dart';

/// 气候带选择器 Widget
class ClimateZoneSelector extends ConsumerWidget {
  const ClimateZoneSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClimate = ref.watch(selectedClimateZoneProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: ClimateZone.values.length,
          itemBuilder: (context, index) {
            final climate = ClimateZone.values[index];
            final isSelected = selectedClimate == climate;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () {
                  ref.read(selectedClimateZoneProvider.notifier).state = climate;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getClimateEmoji(climate),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        climate.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getClimateEmoji(ClimateZone climate) {
    switch (climate) {
      case ClimateZone.coldTemperate:
        return '❄️';
      case ClimateZone.temperate:
        return '🌤️';
      case ClimateZone.warmTemperate:
        return '☀️';
      case ClimateZone.subtropical:
        return '🌴';
      case ClimateZone.tropical:
        return '🌺';
      case ClimateZone.plateau:
        return '🏔️';
    }
  }
}
