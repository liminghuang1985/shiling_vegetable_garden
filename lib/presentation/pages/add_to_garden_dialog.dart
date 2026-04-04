import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/vegetable.dart';
import '../providers/providers.dart';

/// 添加蔬菜到菜园对话框
class AddToGardenDialog extends ConsumerStatefulWidget {
  final Vegetable vegetable;

  const AddToGardenDialog({
    super.key,
    required this.vegetable,
  });

  @override
  ConsumerState<AddToGardenDialog> createState() => _AddToGardenDialogState();
}

class _AddToGardenDialogState extends ConsumerState<AddToGardenDialog> {
  DateTime _sowDate = DateTime.now();
  BalconyDirection? _sunlight;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(widget.vegetable.category.emoji),
          const SizedBox(width: 8),
          Expanded(child: Text('添加 ${widget.vegetable.name}')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 播种日期
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('播种日期'),
              subtitle: Text(
                '${_sowDate.year}-${_sowDate.month.toString().padLeft(2, '0')}-${_sowDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectSowDate(),
            ),

            const SizedBox(height: 16),

            // 阳台朝向
            const Text(
              '阳台朝向（可选）',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BalconyDirection.values.map((direction) {
                final isSelected = _sunlight == direction;
                return ChoiceChip(
                  label: Text('${direction.emoji} ${direction.label}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _sunlight = selected ? direction : null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 提示信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '预计 ${widget.vegetable.planting.maturityDays} 天后可以收获',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => _addToGarden(),
          child: const Text('确认添加'),
        ),
      ],
    );
  }

  Future<void> _selectSowDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _sowDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _sowDate = date;
      });
    }
  }

  void _addToGarden() {
    ref.read(gardenNotifierProvider.notifier).addVegetable(
          vegetableId: widget.vegetable.id,
          vegetableName: widget.vegetable.name,
          sowDate: _sowDate,
          sunlight: _sunlight,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.vegetable.name} 已添加到菜园！'),
        action: SnackBarAction(
          label: '查看',
          onPressed: () {
            // 可以导航到菜园页面
          },
        ),
      ),
    );
  }
}
