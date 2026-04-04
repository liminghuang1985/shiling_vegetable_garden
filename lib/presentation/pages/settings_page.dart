import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../data/data_seeder.dart';
import '../providers/providers.dart';
import '../../data/datasources/settings_local_datasource.dart';

/// 设置页
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _reminderHarvest = true;
  bool _reminderWater = true;
  bool _reminderFertilize = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = SettingsLocalDatasource();
    final enabled = await settings.getNotificationsEnabled();
    final reminders = await settings.getReminderSettings();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _reminderHarvest = reminders['harvest']!;
        _reminderWater = reminders['water']!;
        _reminderFertilize = reminders['fertilize']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // 阳台朝向
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.wb_sunny, color: Colors.white),
            ),
            title: const Text('阳台朝向'),
            subtitle: Text(_getBalconyLabel()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBalconyDirectionPicker(context, ref),
          ),

          const Divider(),

          // 提醒设置
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.purple,
              child: Icon(Icons.notifications_active, color: Colors.white),
            ),
            title: const Text('提醒设置'),
            subtitle: const Text('收获提醒、浇水提醒等'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReminderSettings(context, ref),
          ),

          const Divider(),

          // 通知开关
          SwitchListTile(
            secondary: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            title: const Text('推送通知'),
            subtitle: const Text('收获提醒、浇水提醒等'),
            value: _notificationsEnabled,
            onChanged: (value) {
              _toggleNotifications(context, value);
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
                    onTap: () async {
                      // 持久化气候带选择
                      final settings = SettingsLocalDatasource();
                      await settings.saveSelectedClimate(climate.name);

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
              await DataSeeder.forceReSeed();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已重置')),
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

  String _getBalconyLabel() {
    final balcony = ref.watch(balconyDirectionProvider);
    return balcony.label;
  }

  void _showBalconyDirectionPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择阳台朝向', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ...BalconyDirection.values.map((b) => ListTile(
              leading: CircleAvatar(
                backgroundColor: ref.watch(balconyDirectionProvider) == b
                    ? Colors.teal
                    : Colors.grey.shade200,
                child: Text(_balconyEmoji(b)),
              ),
              title: Text(b.label),
              subtitle: Text(b.description),
              trailing: ref.watch(balconyDirectionProvider) == b
                  ? const Icon(Icons.check, color: Colors.teal)
                  : null,
              onTap: () async {
                final settings = SettingsLocalDatasource();
                await settings.saveBalconyDirection(b.name);
                ref.read(balconyDirectionProvider.notifier).state = b;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已保存阳台朝向：${b.label}')),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  String _balconyEmoji(BalconyDirection d) {
    switch (d) {
      case BalconyDirection.north: return '🧭';
      case BalconyDirection.south: return '☀️';
      case BalconyDirection.east: return '🌅';
      case BalconyDirection.west: return '🌇';
      case BalconyDirection.none: return '🏠';
    }
  }

  void _showReminderSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('提醒设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('收获提醒'),
                subtitle: const Text('蔬菜成熟时通知'),
                value: _reminderHarvest,
                onChanged: (v) => setState(() => _reminderHarvest = v),
              ),
              SwitchListTile(
                title: const Text('浇水提醒'),
                subtitle: const Text('按种植日历定时提醒'),
                value: _reminderWater,
                onChanged: (v) => setState(() => _reminderWater = v),
              ),
              SwitchListTile(
                title: const Text('施肥提醒'),
                subtitle: const Text('定期施肥提醒'),
                value: _reminderFertilize,
                onChanged: (v) => setState(() => _reminderFertilize = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final settings = SettingsLocalDatasource();
                  await settings.saveReminderSettings(_reminderHarvest, _reminderWater, _reminderFertilize);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('提醒设置已保存')),
                  );
                },
                child: const Text('保存设置'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleNotifications(BuildContext context, bool value) {
    setState(() => _notificationsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? '推送通知已开启' : '推送通知已关闭'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

}
