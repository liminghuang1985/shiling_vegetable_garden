import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/garden_vegetable.dart';
import '../providers/providers.dart';
import '../widgets/garden_vegetable_card.dart';
import 'garden_detail_page.dart';

/// 我的菜园页
class MyGardenPage extends ConsumerWidget {
  const MyGardenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gardenAsync = ref.watch(myGardenProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('我的菜园'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: '生长中'),
              Tab(text: '已收获'),
              Tab(text: '已取消'),
            ],
          ),
        ),
        body: gardenAsync.when(
          data: (vegetables) {
            final filtered = _filterByStatus(vegetables, selectedStatus);

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getEmptyIcon(selectedStatus),
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getEmptyMessage(selectedStatus),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (selectedStatus == GardenStatus.growing) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 跳转到蔬菜列表
                          DefaultTabController.of(context).animateTo(0);
                        },
                        icon: const Icon(Icons.eco),
                        label: const Text('去种植'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myGardenProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final gv = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GardenVegetableCard(
                      gardenVegetable: gv,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GardenDetailPage(gardenVegetable: gv),
                          ),
                        );
                      },
                      onHarvest: gv.status == GardenStatus.growing
                          ? () => _showHarvestDialog(context, ref, gv)
                          : null,
                      onDelete: () => _showDeleteDialog(context, ref, gv),
                    ),
                  );
                },
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
                  onPressed: () => ref.invalidate(myGardenProvider),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<GardenVegetable> _filterByStatus(
    List<GardenVegetable> vegetables,
    GardenStatus status,
  ) {
    return vegetables.where((v) => v.status == status).toList();
  }

  IconData _getEmptyIcon(GardenStatus status) {
    switch (status) {
      case GardenStatus.growing:
        return Icons.yard_outlined;
      case GardenStatus.harvested:
        return Icons.check_circle_outline;
      case GardenStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getEmptyMessage(GardenStatus status) {
    switch (status) {
      case GardenStatus.growing:
        return '还没有种植蔬菜\n去蔬菜库看看吧';
      case GardenStatus.harvested:
        return '还没有收获记录';
      case GardenStatus.cancelled:
        return '没有取消的种植';
    }
  }

  void _showHarvestDialog(
    BuildContext context,
    WidgetRef ref,
    GardenVegetable gv,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认收获'),
        content: Text('确定要收获 "${gv.vegetableName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gardenNotifierProvider.notifier).harvest(gv.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${gv.vegetableName} 已收获！')),
              );
            },
            child: const Text('确认收获'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    GardenVegetable gv,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${gv.vegetableName}" 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(gardenNotifierProvider.notifier).delete(gv.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已删除')),
              );
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// TabBar 状态 Provider
final selectedStatusProvider = StateProvider<GardenStatus>((ref) {
  return GardenStatus.growing;
});
