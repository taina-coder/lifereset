import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:life_reset/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Adicionado o parâmetro obrigatório startWithOnboarding
    await tester.pumpWidget(const LifeResetApp(startWithOnboarding: false));

    // O restante do teste pode permanecer igual, 
    // mas note que se o seu app não tiver um contador na Home, 
    // este teste padrão do Flutter irá falhar na execução.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}