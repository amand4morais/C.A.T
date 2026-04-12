import 'package:flutter_test/flutter_test.dart';

import 'package:cat_cursos/main.dart';

void main() {
  testWidgets('Exibe tela de login na inicialização', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CatApp());
    await tester.pumpAndSettle();

    expect(find.text('RA'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Não tem conta? Cadastre-se'), findsOneWidget);
  });
}
