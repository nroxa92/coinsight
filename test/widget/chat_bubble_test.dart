import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coinsight/widgets/chat_bubble.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ChatBubble', () {
    testWidgets('user message aligns right', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ChatBubble(text: 'Hello', isUser: true),
      ));

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('assistant message aligns left', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ChatBubble(text: 'Hi there', isUser: false),
      ));

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('text is selectable', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ChatBubble(text: 'Selectable text', isUser: true),
      ));

      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('Selectable text'), findsOneWidget);
    });
  });
}
