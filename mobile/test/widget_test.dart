import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_master/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const VocabMasterApp());
    expect(find.text('VocabMaster'), findsOneWidget);
  });
}
