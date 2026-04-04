import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/garden_vegetable.dart';
import '../../core/utils/date_utils.dart';

/// 菜园蔬菜卡片 Widget
class GardenVegetableCard extends StatelessWidget {
  final GardenVegetable gardenVegetable;
  final VoidCallback? onTap;
  final VoidCallback? onHarvest;
  final VoidCallback? onDelete;

  const GardenVegetableCard({
    super.key,
    required this.gardenVegetable,
    this.onTap,
    this.onHarvest,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 状态图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    gardenVegetable.status.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gardenVegetable.vegetableName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '播种 ${DateTimeUtils.formatDate(gardenVegetable.sowDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (gardenVegetable.status == GardenStatus.growing) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.timeline,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '已生长 ${gardenVegetable.daysSinceSow} 天',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (gardenVegetable.sunlight != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.wb_sunny,
                            size: 14,
                            color: Colors.orange.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            gardenVegetable.sunlight!.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 操作按钮
              Column(
                children: [
                  if (onHarvest != null)
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: onHarvest,
                      tooltip: '收获',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey.shade400),
                      onPressed: onDelete,
                      tooltip: '删除',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (gardenVegetable.status) {
      case GardenStatus.growing:
        return Colors.green;
      case GardenStatus.harvested:
        return Colors.blue;
      case GardenStatus.cancelled:
        return Colors.grey;
    }
  }
}
