import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/vegetable_local_datasource.dart';
import '../../data/models/vegetable_model.dart';
import '../providers/providers.dart';
import 'vegetable_detail_page.dart';

/// 蔬菜库页面
class VegetableLibraryPage extends ConsumerStatefulWidget {
  const VegetableLibraryPage({super.key});

  @override
  ConsumerState<VegetableLibraryPage> createState() => _VegetableLibraryPageState();
}

class _VegetableLibraryPageState extends ConsumerState<VegetableLibraryPage> {
  bool _isGridView = false;
  String _searchQuery = '';
  VegetableCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datasource = ref.watch(vegetableLocalDatasourceProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterBar(),
            Expanded(child: _buildContent(datasource)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            '🥬',
            style: TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '蔬菜库',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: AppTheme.primaryGreen,
            ),
            tooltip: _isGridView ? '列表视图' : '网格视图',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: '搜索蔬菜名称...',
          hintStyle: TextStyle(color: AppTheme.textLight),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 字母排序标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_by_alpha, size: 16, color: AppTheme.primaryGreen),
                SizedBox(width: 4),
                Text(
                  'A-Z',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 类型筛选下拉
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<VegetableCategory?>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  hint: const Text('全部类型', style: TextStyle(fontSize: 13)),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('全部类型'),
                    ),
                    ...VegetableCategory.values.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Text(cat.emoji),
                              const SizedBox(width: 6),
                              Text(cat.label),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(VegetableLocalDatasource datasource) {
    return FutureBuilder<List<VegetableModel>>(
      future: datasource.getAllVegetables(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                const SizedBox(height: 12),
                Text(
                  '加载失败: ${snapshot.error}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        final allVegetables = snapshot.data ?? [];

        // 过滤
        var vegetables = allVegetables.where((v) {
          // 搜索过滤
          final matchesSearch = _searchQuery.isEmpty ||
              v.name.contains(_searchQuery) ||
              (v.alias?.contains(_searchQuery) ?? false);
          // 分类过滤
          final matchesCategory = _selectedCategory == null ||
              v.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        // A-Z 排序
        vegetables.sort((a, b) => a.name.compareTo(b.name));

        if (vegetables.isEmpty) {
          return _buildEmptyState();
        }

        if (_isGridView) {
          return _buildGridView(vegetables);
        } else {
          return _buildListView(vegetables);
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥬', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? '没有找到匹配的蔬菜'
                : '暂无蔬菜数据',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = null;
                });
              },
              child: const Text('清除筛选'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListView(List<VegetableModel> vegetables) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vegetables.length,
      itemBuilder: (context, index) {
        final veg = vegetables[index];
        return _buildListTile(veg);
      },
    );
  }

  Widget _buildListTile(VegetableModel veg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _navigateToDetail(veg),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              veg.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          veg.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          veg.alias != null ? '${veg.alias} · ${veg.category.label}' : veg.category.label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildGridView(List<VegetableModel> vegetables) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: vegetables.length,
      itemBuilder: (context, index) {
        final veg = vegetables[index];
        return _buildGridCard(veg);
      },
    );
  }

  Widget _buildGridCard(VegetableModel veg) {
    return InkWell(
      onTap: () => _navigateToDetail(veg),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              veg.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              veg.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              veg.category.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(VegetableModel veg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VegetableDetailPage(vegetable: veg.toEntity()),
      ),
    );
  }
}
