import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prorider_merchant_app/main.dart';

void main() {
  testWidgets('Merchant app smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MerchantApp()));
    expect(find.text('ProRider Merchant'), findsOneWidget);
  });
}
