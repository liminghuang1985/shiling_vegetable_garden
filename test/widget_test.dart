import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiling_vegetable_garden/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ShilingVegetableGardenApp(),
      ),
    );

    // Verify that app launches with bottom navigation
    expect(find.text('蔬菜'), findsOneWidget);
    expect(find.text('我的菜园'), findsOneWidget);
    expect(find.text('种植日历'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}
