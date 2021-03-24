import 'package:flutter/material.dart';
import 'package:flutter_example/util/translation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expected_results.dart';
import 'test_app.dart';

void main() {
  testWidgets('Translation without separator test',
      (WidgetTester tester) async {
    List<String> expectedTexts = getExpectedSeparatorTexts();

    String simpleId = TranslationKeys.oneTwoDotSimple;

    String interceptedId = TranslationKeys.oneTwoDotAmount;

    List<String> Function(BuildContext context) getTranslationList =
        (BuildContext context) {
      return [
        Translation.of(context).oneDotSimple,
        Translation.of(context).resolve(simpleId),
        Translation.of(context).oneTwoThreeDotSimple,
        Translation.of(context).oneDotAmount([1]),
        Translation.of(context).resolve(interceptedId)([1]),
        Translation.of(context).oneTwoThreeDotAmount([1]),
        Translation.of(context).nestedOne
      ];
    };

    // Build our app and trigger a frame.
    await tester.pumpWidget(TestApp(
      localizationDelegate: Translation.delegate,
      getTranslationList: getTranslationList,
    ));
    await tester.pumpAndSettle();

    for (var i = 0; i < expectedTexts.length; i++) {
      expect(find.text(expectedTexts[i]), findsOneWidget);
    }
  });
}
