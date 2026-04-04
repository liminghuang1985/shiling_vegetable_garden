import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/garden_vegetable.dart';
import '../providers/providers.dart';

/// 菜园详情页
class GardenDetailPage extends ConsumerStatefulWidget {
  final GardenVegetable gardenVegetable;

  const GardenDetailPage({
    super.key,
    required this.gardenVegetable,
  });

  @override
  ConsumerState<GardenDetailPage> createState() => _GardenDetailPageState();
}

class _GardenDetailPageState extends ConsumerState<GardenDetailPage> {
  @override
  Widget build(BuildContext context) {
    final gardenAsync = ref.watch(gardenVegetableDetailsProvider(widget.gardenVegetable.id));

    return gardenAsync.when(
      data: (garden) {
        if (garden == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('菜园详情')),
            body: const Center(child: Text('未找到')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(garden.vegetableName),
            actions: [
              if (garden.status == GardenStatus.growing)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, garden),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'harvest',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('收获'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('取消种植'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 状态卡片
                _buildStatusCard(garden),

                const SizedBox(height: 16),

                // 种植信息
                _buildPlantingInfoCard(garden),

                const SizedBox(height: 16),

                // 生长日志
                _buildLogsCard(garden),

                const SizedBox(height: 16),

                // 提醒
                _buildRemindersCard(garden),
              ],
            ),
          ),
          floatingActionButton: garden.status == GardenStatus.growing
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'add_log',
                      onPressed: () => _showAddLogDialog(garden),
                      child: const Icon(Icons.note_add),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: 'add_reminder',
                      onPressed: () => _showAddReminderDialog(garden),
                      child: const Icon(Icons.alarm_add),
                    ),
                  ],
                )
              : null,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('菜园详情')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('菜园详情')),
        body: Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildStatusCard(GardenVegetable garden) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              garden.status.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garden.vegetableName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(garden.status.label),
                    backgroundColor: _getStatusColor(garden.status),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantingInfoCard(GardenVegetable garden) {
    return Card(
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
            _buildInfoRow('播种日期', DateTimeUtils.formatDate(garden.sowDate)),
            _buildInfoRow('已生长', '${garden.daysSinceSow} 天'),
            if (garden.sunlight != null)
              _buildInfoRow('阳台朝向', garden.sunlight!.label),
            _buildInfoRow(
              '预计收获',
              DateTimeUtils.formatDate(
                garden.sowDate.add(const Duration(days: 60)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsCard(GardenVegetable garden) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '生长日志',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (garden.logs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '暂无日志\n点击下方按钮添加',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...garden.logs.map(
                (log) => ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.note),
                  ),
                  title: Text(log.note),
                  subtitle: Text(DateTimeUtils.formatRelative(log.date)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersCard(GardenVegetable garden) {
    final pendingReminders = garden.reminders.where((r) => !r.isDone).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '提醒',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (pendingReminders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    '暂无提醒\n点击下方按钮添加',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...pendingReminders.map(
                (reminder) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Text(reminder.type.emoji),
                  ),
                  title: Text(reminder.type.label),
                  subtitle: Text(DateTimeUtils.getFriendlyDate(reminder.time)),
                  trailing: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      ref
                          .read(gardenNotifierProvider.notifier)
                          .markReminderDone(reminder.id);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(GardenStatus status) {
    switch (status) {
      case GardenStatus.growing:
        return Colors.green;
      case GardenStatus.harvested:
        return Colors.blue;
      case GardenStatus.cancelled:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action, GardenVegetable garden) {
    switch (action) {
      case 'harvest':
        ref.read(gardenNotifierProvider.notifier).harvest(garden.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${garden.vegetableName} 已收获！')),
        );
        break;
      case 'cancel':
        ref.read(gardenNotifierProvider.notifier).cancel(garden.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消种植')),
        );
        break;
    }
  }

  void _showAddLogDialog(GardenVegetable garden) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加日志'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '记录内容',
            hintText: '例如：叶子长出来了',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(gardenNotifierProvider.notifier).addLog(
                      gardenId: garden.id,
                      note: controller.text,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('日志已添加')),
                );
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(GardenVegetable garden) {
    ReminderType selectedType = ReminderType.water;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加提醒'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ReminderType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: '提醒类型'),
                items: ReminderType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text('${type.emoji} ${type.label}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('提醒时间'),
                subtitle: Text(DateTimeUtils.formatDate(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(gardenNotifierProvider.notifier).addReminder(
                      gardenId: garden.id,
                      type: selectedType,
                      time: selectedDate,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('提醒已添加')),
                );
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
}
