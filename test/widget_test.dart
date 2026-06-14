// Yeniden kullanılabilir AppCard bileşeni için widget testi.
// (Önceki varsayılan "Counter" smoke testi bu uygulamayla uyuşmuyordu —
//  MyApp Provider/Firebase gerektirdiği için başarısız oluyordu; kaldırıldı.)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/widgets/app_card.dart';

void main() {
  testWidgets('AppCard çocuğunu render eder (koyu tema)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        theme: null,
        home: Scaffold(
          body: AppCard(child: Text('merhaba')),
        ),
      ),
    );

    expect(find.text('merhaba'), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
  });
}
