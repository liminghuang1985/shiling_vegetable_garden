import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/city.dart';
import '../providers/providers.dart';
import '../../data/datasources/settings_local_datasource.dart';

/// 城市选择页
class CitySelectionPage extends ConsumerStatefulWidget {
  const CitySelectionPage({super.key});

  @override
  ConsumerState<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends ConsumerState<CitySelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  ClimateZone? _selectedClimate;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(allCitiesProvider);
    final currentClimate = ref.watch(selectedClimateZoneProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('选择城市'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 搜索输入框
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: '搜索城市...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 气候带快速筛选
                const Text(
                  '按气候区筛选',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildClimateChip(null, '全部', null),
                      ...ClimateZone.values.map(
                        (zone) => _buildClimateChip(
                          zone,
                          _getClimateShortName(zone),
                          _getClimateEmoji(zone),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 当前选择提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.primaryGreen.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  '当前选择：${_getClimateShortName(currentClimate)}',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 城市列表
          Expanded(
            child: citiesAsync.when(
              data: (allCities) {
                // 过滤城市
                var cities = allCities;

                // 按气候区筛选
                if (_selectedClimate != null) {
                  cities = cities.where((c) => c.climate == _selectedClimate).toList();
                }

                // 按搜索词筛选
                if (_searchQuery.isNotEmpty) {
                  cities = cities
                      .where((c) =>
                          c.name.contains(_searchQuery) ||
                          c.province.contains(_searchQuery))
                      .toList();
                }

                // 按省份分组
                final groupedCities = _groupCitiesByProvince(cities);

                if (cities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? '未找到"$_searchQuery"相关城市'
                              : '该气候区暂无城市数据',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: groupedCities.length,
                  itemBuilder: (context, index) {
                    final province = groupedCities.keys.elementAt(index);
                    final provinceCities = groupedCities[province]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 省份标题
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  province,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${provinceCities.length}个城市',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 城市列表
                        ...provinceCities.map(
                          (city) => _buildCityTile(city, currentClimate),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: 16),
                    const Text('加载城市失败'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(allCitiesProvider),
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

  Widget _buildClimateChip(ClimateZone? zone, String label, String? emoji) {
    final isSelected = _selectedClimate == zone;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedClimate = zone;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(City city, ClimateZone currentClimate) {
    final isSelected = city.climate == currentClimate;

    return InkWell(
      onTap: () async {
        // 持久化城市选择
        final settings = SettingsLocalDatasource();
        await settings.saveSelectedCityId(city.id ?? 0);
        await settings.saveSelectedClimate(city.climate.name);

        ref.read(selectedClimateZoneProvider.notifier).state = city.climate;
        ref.invalidate(currentRecommendedVegetablesProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(_getClimateEmoji(city.climate)),
                const SizedBox(width: 8),
                Text('已切换到${city.climate.label} · ${city.name}'),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.08)
              : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getClimateEmoji(city.climate),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    city.climate.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppTheme.primaryGreen.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Map<String, List<City>> _groupCitiesByProvince(List<City> cities) {
    final Map<String, List<City>> grouped = {};
    for (final city in cities) {
      if (!grouped.containsKey(city.province)) {
        grouped[city.province] = [];
      }
      grouped[city.province]!.add(city);
    }
    return grouped;
  }

  String _getClimateShortName(ClimateZone zone) {
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

  String _getClimateEmoji(ClimateZone zone) {
    switch (zone) {
      case ClimateZone.coldTemperate:
        return '❄️';
      case ClimateZone.temperate:
        return '🌤️';
      case ClimateZone.warmTemperate:
        return '☀️';
      case ClimateZone.subtropical:
        return '🌴';
      case ClimateZone.tropical:
        return '🌺';
      case ClimateZone.plateau:
        return '🏔️';
    }
  }
}
