import 'package:flutter/material.dart';
import 'package:flutter_example/util/translation_with_interceptors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expected_results.dart';
import 'test_app.dart';

void main() {
  testWidgets('Translation with interceptor test', (WidgetTester tester) async {
    List<String> expectedTexts = getExpectedInterceptedTexts();

    List<String> Function(BuildContext context) getTranslationList =
        (BuildContext context) {
      return [
        TranslationWithInterceptors.of(context).interceptorSimple,
        TranslationWithInterceptors.of(context).interceptorFiltered,
      ];
    };
    // Build our app and trigger a frame.
    await tester.pumpWidget(TestApp(
      localizationDelegate: TranslationWithInterceptors.delegate,
      getTranslationList: getTranslationList,
    ));
    await tester.pumpAndSettle();

    for (var i = 0; i < expectedTexts.length; i++) {
      expect(find.text(expectedTexts[i]), findsOneWidget);
    }
  });
}
