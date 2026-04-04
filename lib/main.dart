import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/database_helper.dart';
import 'data/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  // 初始化预设数据（如果数据库为空）
  final seeder = DataSeeder(dbHelper);
  await seeder.seedIfNeeded();

  runApp(
    const ProviderScope(
      child: ShilingVegetableGardenApp(),
    ),
  );
}
