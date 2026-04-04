import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/vegetable.dart';
import '../providers/providers.dart';
import '../widgets/vegetable_card.dart';
import '../widgets/climate_zone_selector.dart';
import 'vegetable_detail_page.dart';

/// 蔬菜列表页
class VegetableListPage extends ConsumerWidget {
  const VegetableListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch climate zone to trigger rebuilds when it changes
    ref.watch(selectedClimateZoneProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final vegetablesAsync = ref.watch(filteredVegetablesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('时令蔬菜'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: VegetableSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 气候带选择器
          const ClimateZoneSelector(),

          // 分类筛选
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildCategoryChip(ref, null, '全部', selectedCategory),
                ...VegetableCategory.values.map(
                  (cat) => _buildCategoryChip(
                    ref,
                    cat,
                    '${cat.emoji} ${cat.label}',
                    selectedCategory,
                  ),
                ),
              ],
            ),
          ),

          // 蔬菜列表
          Expanded(
            child: vegetablesAsync.when(
              data: (vegetables) {
                if (vegetables.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无蔬菜数据',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: vegetables.length,
                  itemBuilder: (context, index) {
                    final veg = vegetables[index];
                    return VegetableCard(
                      vegetable: veg,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VegetableDetailPage(vegetable: veg),
                          ),
                        );
                      },
                    );
                  },
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
                      onPressed: () => ref.invalidate(filteredVegetablesProvider),
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

  Widget _buildCategoryChip(
    WidgetRef ref,
    VegetableCategory? category,
    String label,
    VegetableCategory? selectedCategory,
  ) {
    final isSelected = category == selectedCategory;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(selectedCategoryProvider.notifier).state =
              selected ? category : null;
        },
      ),
    );
  }
}

/// 蔬菜搜索代理
class VegetableSearchDelegate extends SearchDelegate<Vegetable?> {
  final WidgetRef ref;

  VegetableSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('输入蔬菜名称搜索'),
      );
    }

    return FutureBuilder(
      future: ref.read(vegetableRepositoryProvider).searchVegetables(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vegetables = snapshot.data ?? [];

        if (vegetables.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('未找到"$query"相关蔬菜'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: vegetables.length,
          itemBuilder: (context, index) {
            final veg = vegetables[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(veg.category.emoji),
              ),
              title: Text(veg.name),
              subtitle: Text(veg.alias ?? veg.category.label),
              trailing: Text(veg.category.label),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VegetableDetailPage(vegetable: veg),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
