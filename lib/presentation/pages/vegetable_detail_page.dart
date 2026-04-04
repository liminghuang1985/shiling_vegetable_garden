import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vegetable.dart';
import '../../core/constants/enums.dart';
import '../providers/providers.dart';
import 'add_to_garden_dialog.dart';

/// 蔬菜详情页
class VegetableDetailPage extends ConsumerWidget {
  final Vegetable vegetable;

  const VegetableDetailPage({
    super.key,
    required this.vegetable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClimate = ref.watch(selectedClimateZoneProvider);
    final isSuitable = vegetable.suitableClimates.contains(selectedClimate);

    return Scaffold(
      appBar: AppBar(
        title: Text(vegetable.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vegetable.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vegetable.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (vegetable.alias != null)
                                Text(
                                  '别名: ${vegetable.alias}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(vegetable.category.label),
                                avatar: Text(vegetable.emoji),
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

            const SizedBox(height: 16),

            // 气候带适配
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.public, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '气候带适配',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (isSuitable)
                          const Chip(
                            label: Text('适合本地'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ClimateZone.values.map((climate) {
                        final suitable = vegetable.suitableClimates.contains(climate);
                        return Chip(
                          label: Text(climate.label),
                          backgroundColor:
                              suitable ? Colors.green.shade100 : Colors.grey.shade200,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 生长条件
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          '生长条件',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('温度范围', vegetable.tempRange),
                    _buildInfoRow('光照需求', vegetable.sunlight.label),
                    _buildInfoRow('光照说明', vegetable.sunlight.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 土壤要求
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.grass, color: Colors.brown),
                        const SizedBox(width: 8),
                        Text(
                          '土壤要求',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('土壤类型', vegetable.soil.type),
                    _buildInfoRow('pH值', vegetable.soil.phRange),
                    _buildInfoRow('排水性', vegetable.soil.drainage),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 肥料建议
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          '肥料建议',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('基肥', vegetable.fertilizer.base),
                    _buildInfoRow('追肥', vegetable.fertilizer.top),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 种植信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.agriculture, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '种植信息',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('播种深度', '${vegetable.planting.depthCm} cm'),
                    _buildInfoRow('株距', '${vegetable.planting.spacingCm} cm'),
                    _buildInfoRow('行距', '${vegetable.planting.rowSpacingCm} cm'),
                    _buildInfoRow('发芽天数', '${vegetable.planting.germinationDays} 天'),
                    _buildInfoRow('成熟天数', '${vegetable.planting.maturityDays} 天'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 营养成分
            if (vegetable.nutrients.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            '营养成分',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: vegetable.nutrients
                            .map((n) => Chip(label: Text(n)))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 注意事项
            if (vegetable.cautions.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            '注意事项',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...vegetable.cautions.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(c)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 80), // 底部空间
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddToGardenDialog(vegetable: vegetable),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('添加到菜园'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
