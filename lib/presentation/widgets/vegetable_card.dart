import 'package:flutter/material.dart';
import '../../domain/entities/vegetable.dart';
import '../../core/constants/enums.dart';

/// 蔬菜卡片 Widget
class VegetableCard extends StatelessWidget {
  final Vegetable vegetable;
  final VoidCallback? onTap;

  const VegetableCard({
    super.key,
    required this.vegetable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            Container(
              height: 80,
              width: double.infinity,
              color: _getCategoryColor(vegetable.category).withValues(alpha: 0.2),
              child: Center(
                child: Text(
                  vegetable.category.emoji,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),

            // 内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vegetable.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (vegetable.alias != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        vegetable.alias!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.thermostat,
                          size: 14,
                          color: _getTempColor(vegetable.minTemp),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vegetable.tempRange,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 14,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vegetable.sunlight.label,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(VegetableCategory category) {
    switch (category) {
      case VegetableCategory.leafy:
        return Colors.green;
      case VegetableCategory.fruit:
        return Colors.red;
      case VegetableCategory.root:
        return Colors.orange;
      case VegetableCategory.legume:
        return Colors.purple;
      case VegetableCategory.herb:
        return Colors.teal;
    }
  }

  Color _getTempColor(double temp) {
    if (temp <= 5) return Colors.blue;
    if (temp <= 10) return Colors.cyan;
    if (temp <= 15) return Colors.teal;
    return Colors.orange;
  }
}
