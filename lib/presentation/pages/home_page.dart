import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../providers/providers.dart';
import '../widgets/vegetable_card.dart';
import 'vegetable_detail_page.dart';
import 'city_selection_page.dart';
import 'my_garden_page.dart';
import 'planting_calendar_page.dart';

/// 首页 - 时令蔬菜推荐
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeContent(),
    _MyGardenContent(),
    _CalendarContent(),
    _SettingsContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.eco_outlined, Icons.eco, '首页'),
                _buildNavItem(1, Icons.yard_outlined, Icons.yard, '菜园'),
                _buildNavItem(2, Icons.calendar_month_outlined, Icons.calendar_month, '日历'),
                _buildNavItem(3, Icons.settings_outlined, Icons.settings, '设置'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首页内容
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClimate = ref.watch(selectedClimateZoneProvider);
    final selectedDirection = ref.watch(balconyDirectionProvider);
    final vegetablesAsync = ref.watch(currentRecommendedVegetablesProvider);
    final currentMonth = DateTime.now().month;

    return CustomScrollView(
      slivers: [
        // 顶部气候区信息
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryGreen, Color(0xFF4A7C43)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部标题行
                    Row(
                      children: [
                        const Text(
                          '🌱',
                          style: TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '时令菜园',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        // 城市选择按钮
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CitySelectionPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getClimateZoneName(selectedClimate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 月份和季节信息
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              DateTimeUtils.getMonthName(currentMonth),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '现在是种植${_getSeasonVerb(currentMonth)}的最佳时节',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_getClimateDescription(selectedClimate)} · ${DateTimeUtils.getSeasonName(currentMonth)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 阳台朝向快速选择
                    const Text(
                      '您的阳台朝向',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final direction in [BalconyDirection.east, BalconyDirection.south, BalconyDirection.west, BalconyDirection.north, BalconyDirection.none])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: _DirectionChip(
                                direction: direction,
                                isSelected: selectedDirection == direction,
                                onTap: () {
                                  ref.read(balconyDirectionProvider.notifier).state = direction;
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 本月推荐标题
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '本月推荐种植',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                Text(
                  '${DateTimeUtils.getMonthName(currentMonth)}可种',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 蔬菜列表
        vegetablesAsync.when(
          data: (vegetables) {
            if (vegetables.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyState(context),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                  childCount: vegetables.length,
                ),
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
          error: (error, _) => SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 64,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '数据加载失败',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(currentRecommendedVegetablesProvider),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_outlined,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无推荐蔬菜',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '请先选择城市和阳台朝向',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),

        ],
      ),
    );
  }

  String _getClimateZoneName(ClimateZone zone) {
    switch (zone) {
      case ClimateZone.coldTemperate:
        return '东北寒区';
      case ClimateZone.temperate:
        return '华北温带';
      case ClimateZone.warmTemperate:
        return '暖温带';
      case ClimateZone.subtropical:
        return '华中亚热带';
      case ClimateZone.tropical:
        return '华南高温区';
      case ClimateZone.plateau:
        return '西南高原区';
    }
  }

  String _getClimateDescription(ClimateZone zone) {
    switch (zone) {
      case ClimateZone.coldTemperate:
        return '一年一熟，5-9月盛夏种菜';
      case ClimateZone.temperate:
        return '两年三熟，4-10月露地种菜';
      case ClimateZone.warmTemperate:
        return '喜温菜全年可种';
      case ClimateZone.subtropical:
        return '一年两熟，2-12月可种';
      case ClimateZone.tropical:
        return '全年可种';
      case ClimateZone.plateau:
        return '海拔差异大，因地制宜';
    }
  }

  String _getSeasonVerb(int month) {
    if (month >= 2 && month <= 4) return '春播';
    if (month >= 5 && month <= 7) return '夏播';
    if (month >= 8 && month <= 10) return '秋播';
    return '冬播';
  }
}

/// 朝向选择 Chip
class _DirectionChip extends StatelessWidget {
  final BalconyDirection direction;
  final bool isSelected;
  final VoidCallback onTap;

  const _DirectionChip({
    required this.direction,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              direction.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              direction.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryGreen
                    : Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 我的菜园内容（简化版，后续完善）
class _MyGardenContent extends ConsumerWidget {
  const _MyGardenContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MyGardenPage();
  }
}

/// 日历内容（简化版，后续完善）
class _CalendarContent extends ConsumerWidget {
  const _CalendarContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PlantingCalendarPage();
  }
}

/// 设置内容
class _SettingsContent extends ConsumerWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            icon: Icons.location_on,
            title: '选择城市',
            subtitle: '设置您所在的城市',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CitySelectionPage()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.wb_sunny,
            title: '阳台朝向',
            subtitle: '设置阳台朝向以获得更准的推荐',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: '提醒设置',
            subtitle: '管理种植提醒通知',
            onTap: () {},
          ),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            icon: Icons.info,
            title: '关于时令菜园',
            subtitle: '版本 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
      onTap: onTap,
    );
  }
}
