import 'package:flutter/material.dart';
import 'package:flutter_example/util/translation.dart';
import 'package:flutter_example/util/translation_grouped_underline_separator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expected_results.dart';
import 'test_app.dart';

void main() {
  testWidgets('Translation with dot separator test',
      (WidgetTester tester) async {
    List<String> expectedTexts = getExpectedSeparatorTexts();

    String simpleId = TranslationKeys.oneTwoUnderlineSimple;

    String interceptedId = TranslationKeys.oneTwoUnderlineAmount;

    List<String> Function(BuildContext context) getTranslationList =
        (BuildContext context) {
      return [
        TranslationGroupedUnderlineSeparator.of(context).one.underline.simple,
        TranslationGroupedUnderlineSeparator.of(context).resolve(simpleId),
        TranslationGroupedUnderlineSeparator.of(context)
            .one
            .two
            .three
            .underline
            .simple,
        TranslationGroupedUnderlineSeparator.of(context)
            .one
            .underline
            .amount([1]),
        TranslationGroupedUnderlineSeparator.of(context)
            .resolve(interceptedId)([1]),
        TranslationGroupedUnderlineSeparator.of(context)
            .one
            .two
            .three
            .underline
            .amount([1]),
        TranslationGroupedUnderlineSeparator.of(context).nested.one
      ];
    };
    // Build our app and trigger a frame.
    await tester.pumpWidget(TestApp(
      localizationDelegate: TranslationGroupedUnderlineSeparator.delegate,
      getTranslationList: getTranslationList,
    ));
    await tester.pumpAndSettle();

    for (var i = 0; i < expectedTexts.length; i++) {
      expect(find.text(expectedTexts[i]), findsOneWidget);
    }
  });
}
