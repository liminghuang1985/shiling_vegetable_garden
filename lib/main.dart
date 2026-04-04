import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/database_helper.dart';
import 'data/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化数据库
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.database;

    // 初始化预设数据
    final seeder = DataSeeder(dbHelper);
    await seeder.seedIfNeeded();

    runApp(
      const ProviderScope(
        child: ShilingVegetableGardenApp(),
      ),
    );
  } catch (e, st) {
    debugPrint('=== APP INIT ERROR: $e ===');
    debugPrint('=== STACK: $st ===');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('初始化失败:\n$e', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('堆栈:\n$st', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}