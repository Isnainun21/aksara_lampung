import 'package:flutter_test/flutter_test.dart';
import 'package:kaganga_kids/main.dart';

void main() {
  testWidgets('renders Kaganga Kids splash', (tester) async {
    await tester.pumpWidget(const KagangaKidsApp());

    expect(find.text('Kaganga Kids'), findsOneWidget);
    expect(find.text('Belajar Aksara Lampung'), findsOneWidget);
  });
}
