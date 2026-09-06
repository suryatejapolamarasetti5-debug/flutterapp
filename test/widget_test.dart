import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/portfolio.dart';

void main() {
  testWidgets('Streetlight Complaint portfolio loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PortfolioPage());

    expect(find.byType(PortfolioPage), findsOneWidget);
  });
}