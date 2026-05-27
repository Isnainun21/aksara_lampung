import 'package:flutter_test/flutter_test.dart';
import 'package:kaganga_kids/main.dart';

void main() {
  testWidgets('renders Kaganga splash', (tester) async {
    await tester.pumpWidget(const KagangaKidsApp());

    expect(find.text('Kaganga'), findsOneWidget);
    expect(find.text('Belajar Aksara Lampung'), findsOneWidget);
  });
}
