import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/pest_disease_model.dart';
import '../../data/datasources/pest_disease_local_datasource.dart';
import '../../data/models/vegetable_model.dart';
import '../providers/providers.dart';
import 'pest_disease_detail_page.dart';

/// 病虫害列表页面
class PestDiseaseListPage extends ConsumerStatefulWidget {
  const PestDiseaseListPage({super.key});

  @override
  ConsumerState<PestDiseaseListPage> createState() => _PestDiseaseListPageState();
}

class _PestDiseaseListPageState extends ConsumerState<PestDiseaseListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(child: _buildContent()),
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
          const Text('🐛', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          const Text(
            '病虫害',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final labels = ['按蔬菜', '按类型', '按防治'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        // indicator handled by indicator
        indicator: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: labels.map((l) => Tab(text: l)).toList(),
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _ByVegetableTab(),
        _ByTypeTab(),
        _ByControlModeTab(),
      ],
    );
  }
}

// ========== 按蔬菜 ==========
class _ByVegetableTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasource = PestDiseaseLocalDatasource();

    return FutureBuilder<List<PestDiseaseModel>>(
      future: datasource.getAllPestDiseases(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        final all = snapshot.data!;
        // Group by vegetable ID
        final Map<String, List<PestDiseaseModel>> grouped = {};
        for (final pd in all) {
          for (final vegId in pd.targetVegetables) {
            grouped.putIfAbsent(vegId, () => []).add(pd);
          }
        }

        if (grouped.isEmpty) {
          return _buildEmpty();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final vegId = grouped.keys.elementAt(index);
            final items = grouped[vegId]!;
            return _VegetableGroupCard(vegId: vegId, items: items);
          },
        );
      },
    );
  }
}

class _VegetableGroupCard extends ConsumerWidget {
  final String vegId;
  final List<PestDiseaseModel> items;

  const _VegetableGroupCard({required this.vegId, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasource = ref.watch(vegetableLocalDatasourceProvider);

    return FutureBuilder<VegetableModel?>(
      future: datasource.getVegetableById(vegId),
      builder: (context, snap) {
        String vegName = vegId;
        String vegEmoji = '🥬';
        if (snap.hasData && snap.data != null) {
          vegName = snap.data!.name;
          vegEmoji = snap.data!.emoji;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            leading: Text(vegEmoji, style: const TextStyle(fontSize: 28)),
            title: Text(
              vegName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: Text(
              '${items.length}种病虫害',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            children: items.map((pd) => _PestDiseaseListTile(pd: pd, vegId: vegId)).toList(),
          ),
        );
      },
    );
  }
}

// ========== 按类型 ==========
class _ByTypeTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ByTypeTab> createState() => _ByTypeTabState();
}

class _ByTypeTabState extends ConsumerState<_ByTypeTab> with SingleTickerProviderStateMixin {
  late TabController _typeTabController;

  @override
  void initState() {
    super.initState();
    _typeTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _typeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datasource = PestDiseaseLocalDatasource();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TabBar(
            controller: _typeTabController,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            // indicator handled by indicator
            indicator: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: '全部病害'),
              Tab(text: '全部虫害'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _typeTabController,
            children: [
              _DiseaseList(datasource: datasource),
              _PestList(datasource: datasource),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiseaseList extends StatelessWidget {
  final PestDiseaseLocalDatasource datasource;
  const _DiseaseList({required this.datasource});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PestDiseaseModel>>(
      future: datasource.getByType('disease'),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        final items = snap.data!;
        if (items.isEmpty) return _buildEmpty();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) => _PestDiseaseListTile(pd: items[i], vegId: items[i].targetVegetables.first),
        );
      },
    );
  }
}

class _PestList extends StatelessWidget {
  final PestDiseaseLocalDatasource datasource;
  const _PestList({required this.datasource});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PestDiseaseModel>>(
      future: datasource.getByType('pest'),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        final items = snap.data!;
        if (items.isEmpty) return _buildEmpty();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) => _PestDiseaseListTile(pd: items[i], vegId: items[i].targetVegetables.first),
        );
      },
    );
  }
}

// ========== 按防治模式 ==========
class _ByControlModeTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ByControlModeTab> createState() => _ByControlModeTabState();
}

class _ByControlModeTabState extends ConsumerState<_ByControlModeTab> with SingleTickerProviderStateMixin {
  late TabController _modeTabController;

  final _modes = ['农业预防', '生物防治', '物理防治', '安全用药'];
  final _modeIcons = ['🌾', '🐞', '🪤', '💊'];

  @override
  void initState() {
    super.initState();
    _modeTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _modeTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: TabBar(
            controller: _modeTabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            // indicator handled by indicator
            indicator: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            tabs: List.generate(4, (i) => Tab(text: '${_modeIcons[i]} ${_modes[i]}')),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _modeTabController,
            children: [
              _ControlModeList(datasource: PestDiseaseLocalDatasource(), modeIndex: 0),
              _ControlModeList(datasource: PestDiseaseLocalDatasource(), modeIndex: 1),
              _ControlModeList(datasource: PestDiseaseLocalDatasource(), modeIndex: 2),
              _ControlModeList(datasource: PestDiseaseLocalDatasource(), modeIndex: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlModeList extends StatelessWidget {
  final PestDiseaseLocalDatasource datasource;
  final int modeIndex; // 0=prevention, 1=biological, 2=physical, 3=chemical

  const _ControlModeList({required this.datasource, required this.modeIndex});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PestDiseaseModel>>(
      future: datasource.getAllPestDiseases(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));

        final filtered = snap.data!.where((pd) {
          switch (modeIndex) {
            case 0: return pd.prevention.isNotEmpty;
            case 1: return pd.biological.isNotEmpty;
            case 2: return pd.physical.isNotEmpty;
            case 3: return pd.chemical != null && pd.chemical!.isNotEmpty;
            default: return false;
          }
        }).toList();

        if (filtered.isEmpty) return _buildEmpty();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _PestDiseaseListTile(pd: filtered[i], vegId: filtered[i].targetVegetables.first),
        );
      },
    );
  }
}

// ========== 病虫害列表项 ==========
class _PestDiseaseListTile extends StatelessWidget {
  final PestDiseaseModel pd;
  final String vegId;

  const _PestDiseaseListTile({required this.pd, required this.vegId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PestDiseaseDetailPage(pestDisease: pd),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: pd.isDisease
                ? Colors.red.shade50
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(pd.severityEmoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          pd.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: pd.isDisease ? Colors.red.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pd.typeLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: pd.isDisease ? Colors.red.shade700 : Colors.orange.shade700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _getVegName(vegId),
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
      ),
    );
  }

  String _getVegName(String id) {
    // Simple mapping - in detail page we get full veg info
    final names = {
      'fq': '番茄', 'hg': '黄瓜', 'lj': '辣椒', 'bc': '白菜',
      'jd': '豇豆', 'qz': '茄子', 'lb': '萝卜', 'sc': '生菜',
      'bo': '菠菜', 'gl': '甘蓝',
    };
    return names[id] ?? id;
  }
}

Widget _buildEmpty() {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🐛', style: TextStyle(fontSize: 64)),
        SizedBox(height: 16),
        Text(
          '暂无病虫害数据',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ],
    ),
  );
}
