import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  runApp(
    const ProviderScope(
      child: ShilingVegetableGardenApp(),
    ),
  );
}
