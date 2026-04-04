import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

/// App 根组件
class ShilingVegetableGardenApp extends StatelessWidget {
  const ShilingVegetableGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时令菜园',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
