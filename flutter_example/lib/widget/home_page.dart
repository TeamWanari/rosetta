import 'package:flutter/material.dart';
import 'package:flutter_example/util/translation.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              Translation.of(context).helloThere,
            ),
            Text(
              Translation.of(context).resolve(TranslationKeys.goodIdea),
            ),
            Text(Translation.of(context).oneDotAmount([1])),
            Text(Translation.of(context)
                .resolve(TranslationKeys.oneTwoDotAmount)([1])),
            Text(Translation.of(context).clicked(1)),
            Text(Translation.of(context).clicked(0)),
            Text(Translation.of(context).clicked(1342)),
            Text(Translation.of(context).points(2.00)),
            Text(Translation.of(context).points(-18))
          ],
        ),
      ),
    );
  }
}
