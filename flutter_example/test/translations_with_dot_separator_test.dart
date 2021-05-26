import 'package:flutter/material.dart';
import 'package:flutter_example/util/translation.dart';
import 'package:flutter_example/util/translation_grouped_dot_separator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expected_results.dart';
import 'test_app.dart';

void main() {
  testWidgets('Translation with dot separator test',
      (WidgetTester tester) async {
    List<String> expectedTexts = getExpectedSeparatorTexts();

    String simpleId = TranslationKeys.oneTwoDotSimple;

    String interceptedId = TranslationKeys.oneDotAmount;

    List<String> Function(BuildContext context) getTranslationList =
        (BuildContext context) {
      return [
        TranslationGroupedDotSeparator.of(context).one.dot.simple,
        TranslationGroupedDotSeparator.of(context).resolve(simpleId),
        TranslationGroupedDotSeparator.of(context).one.two.three.dot.simple,
        TranslationGroupedDotSeparator.of(context).resolve(interceptedId)([1]),
        TranslationGroupedDotSeparator.of(context).one.two.dot.amount([1]),
        TranslationGroupedDotSeparator.of(context)
            .one
            .two
            .three
            .dot
            .amount([1]),
        TranslationGroupedDotSeparator.of(context).points(1),
        TranslationGroupedDotSeparator.of(context).points(2),
        TranslationGroupedDotSeparator.of(context).points(15)
      ];
    };
    // Build our app and trigger a frame.
    await tester.pumpWidget(TestApp(
      localizationDelegate: TranslationGroupedDotSeparator.delegate,
      getTranslationList: getTranslationList,
    ));
    await tester.pumpAndSettle();

    for (var i = 0; i < expectedTexts.length; i++) {
      expect(find.text(expectedTexts[i]), findsOneWidget);
    }
  });
}
