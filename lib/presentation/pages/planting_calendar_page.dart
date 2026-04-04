import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/date_utils.dart';
import '../providers/providers.dart';
import '../widgets/climate_zone_selector.dart';
import 'vegetable_detail_page.dart';
import '../../data/datasources/database_helper.dart';

/// 种植日历页
class PlantingCalendarPage extends ConsumerWidget {
  const PlantingCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClimate = ref.watch(selectedClimateZoneProvider);
    final calendarAsync = ref.watch(plantingCalendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('种植日历'),
        actions: [
          IconButton(
            icon: Text('🔧', style: TextStyle(fontSize: 20)),
            onPressed: () async {
              final db = await DatabaseHelper.instance.database;
              final calCount = (await db.query('planting_calendar')).length;
              // Test query for plateau/4
              final april = await db.query(
                'planting_calendar',
                where: 'climate_zone = ? AND month = ?',
                whereArgs: ['plateau', 4],
              );
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('日历Debug'),
                  content: Text(
                    '日历总行数: $calCount\n'
                    '高原4月: ${april.length}行\n'
                    '${april.isNotEmpty ? april.first['vegetable_ids'] : '无数据'}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 气候带选择
          const ClimateZoneSelector(),

          // 日历内容
          Expanded(
            child: calendarAsync.when(
              data: (calendar) {
                final monthData = calendar.data[selectedClimate] ?? {};

                return DefaultTabController(
                  length: 12,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: true,
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.green,
                        tabs: List.generate(
                          12,
                          (index) => Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(DateTimeUtils.getMonthName(index + 1)),
                                if (DateTimeUtils.isCurrentMonth(index + 1))
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.green,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: List.generate(
                            12,
                            (index) {
                              final month = index + 1;
                              final vegIds = monthData[month] ?? [];

                              if (vegIds.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.eco_outlined,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '${DateTimeUtils.getMonthName(month)}不是种植季节',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return _buildMonthVegetables(
                                context,
                                ref,
                                vegIds,
                                selectedClimate,
                                month,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('加载失败: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(plantingCalendarProvider),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthVegetables(
    BuildContext context,
    WidgetRef ref,
    List<String> vegIds,
    ClimateZone climate,
    int month,
  ) {
    return FutureBuilder(
      future: _loadVegetables(ref, vegIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vegetables = snapshot.data ?? [];

        if (vegetables.isEmpty) {
          return const Center(
            child: Text('暂无数据'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vegetables.length,
          itemBuilder: (context, index) {
            final veg = vegetables[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(veg.category.emoji),
                ),
                title: Text(veg.name),
                subtitle: Text(
                  '${veg.category.label} | ${veg.sunlight.label} | ${veg.tempRange}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VegetableDetailPage(vegetable: veg),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _loadVegetables(WidgetRef ref, List<String> vegIds) async {
    final repository = ref.read(vegetableRepositoryProvider);
    final vegetables = <dynamic>[];

    for (final id in vegIds) {
      final veg = await repository.getVegetableById(id);
      if (veg != null) {
        vegetables.add(veg);
      }
    }

    return vegetables;
  }
}
