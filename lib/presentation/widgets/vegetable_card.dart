import 'package:flutter/material.dart';
import '../../domain/entities/vegetable.dart';
import '../../core/theme/app_theme.dart';

/// 蔬菜卡片 Widget - 自然有机风格
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部分类标识区域
            Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getCategoryColor(vegetable.category).withValues(alpha: 0.15),
                    _getCategoryColor(vegetable.category).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // 背景装饰圆
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(vegetable.category)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // 分类 Emoji
                  Center(
                    child: Text(
                      vegetable.category.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  // 温度标签
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.thermostat_outlined,
                            size: 12,
                            color: _getTempColor(vegetable.minTemp),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${vegetable.minTemp.toInt()}°+',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getTempColor(vegetable.minTemp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 蔬菜名称
                    Text(
                      vegetable.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (vegetable.alias != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        vegetable.alias!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),

                    // 光照需求标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSunlightIcon(vegetable.sunlight),
                            size: 12,
                            color: AppTheme.accentOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vegetable.sunlight.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.accentOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 成熟天数
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timeline,
                                size: 12,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${vegetable.planting.maturityDays}天',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

  Color _getCategoryColor(dynamic category) {
    final name = category.toString().split('.').last;
    switch (name) {
      case 'leafy':
        return AppTheme.leafyGreen;
      case 'fruit':
        return AppTheme.fruitRed;
      case 'root':
        return AppTheme.rootOrange;
      case 'legume':
        return AppTheme.legumePurple;
      case 'herb':
        return AppTheme.herbTeal;
      default:
        return AppTheme.lightGreen;
    }
  }

  Color _getTempColor(double minTemp) {
    if (minTemp <= 5) return Colors.blue;
    if (minTemp <= 10) return Colors.cyan;
    if (minTemp <= 15) return Colors.teal;
    return AppTheme.accentOrange;
  }

  IconData _getSunlightIcon(dynamic sunlight) {
    final name = sunlight.toString().split('.').last;
    switch (name) {
      case 'fullSun':
        return Icons.wb_sunny;
      case 'partialSun':
        return Icons.wb_cloudy;
      case 'shade':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }
}
