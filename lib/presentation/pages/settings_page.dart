import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../providers/providers.dart';

/// 设置页
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClimate = ref.watch(selectedClimateZoneProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 气候带设置
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.public, color: Colors.white),
            ),
            title: const Text('气候带'),
            subtitle: Text(selectedClimate.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClimateZonePicker(context, ref),
          ),

          const Divider(),

          // 通知设置
          SwitchListTile(
            secondary: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            title: const Text('推送通知'),
            subtitle: const Text('收获提醒、浇水提醒等'),
            value: true, // TODO: 接入 SharedPreferences
            onChanged: (value) {
              // TODO: 保存设置
            },
          ),

          const Divider(),

          // 关于
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.info, color: Colors.white),
            ),
            title: const Text('关于'),
            subtitle: const Text('时令菜园 v1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),

          const Divider(),

          // 数据管理
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.storage, color: Colors.white),
            ),
            title: const Text('数据管理'),
            subtitle: const Text('清空本地数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showDataManagementDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showClimateZonePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择气候带',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: ClimateZone.values.map((climate) {
                  final isSelected = ref.watch(selectedClimateZoneProvider) == climate;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isSelected ? Colors.green : Colors.grey.shade200,
                      child: Text(
                        _getClimateEmoji(climate),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    title: Text(climate.label),
                    subtitle: Text(climate.region),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      ref.read(selectedClimateZoneProvider.notifier).state =
                          climate;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已切换到${climate.label}')),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getClimateEmoji(ClimateZone climate) {
    switch (climate) {
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '时令菜园',
      applicationVersion: '1.0.0',
      applicationIcon: const Text(
        '🥬',
        style: TextStyle(fontSize: 48),
      ),
      children: const [
        Text('基于中国气候带的时令蔬菜种植指南'),
        SizedBox(height: 16),
        Text('帮助您了解在不同气候带适合种植哪些蔬菜，以及如何正确地种植和护理它们。'),
      ],
    );
  }

  void _showDataManagementDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据管理'),
        content: const Text(
          '清空本地数据将删除所有蔬菜数据、菜园记录和设置。此操作不可恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final dbHelper = ref.read(databaseHelperProvider);
              await dbHelper.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清空')),
              );
              // 刷新页面
              ref.invalidate(myGardenProvider);
            },
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }
}
