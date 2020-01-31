import 'package:flutter/material.dart';

class TestScaffold extends StatefulWidget {
  final LocalizationsDelegate localizationDelegate;

  final Function getTranslationList;

  TestScaffold({this.localizationDelegate, this.getTranslationList});

  @override
  State<StatefulWidget> createState() => TestScaffoldState(
        localizationDelegate: localizationDelegate,
        getTranslationList: getTranslationList,
      );
}

class TestScaffoldState extends State<TestScaffold> {
  final LocalizationsDelegate localizationDelegate;

  final Function getTranslationList;

  TestScaffoldState({this.localizationDelegate, this.getTranslationList});

  @override
  Widget build(BuildContext context) {
    List<String> translationList = getTranslationList(context);

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 32),
        child: ListView.builder(
          itemCount: translationList.length,
          itemBuilder: (BuildContext ctx, int index) {
            return Text(
              translationList[index],
              style: TextStyle(fontSize: 22),
            );
          },
        ),
      ),
    );
  }
}

class TestApp extends StatelessWidget {
  final LocalizationsDelegate localizationDelegate;
  final Function getTranslationList;

  TestApp({this.localizationDelegate, this.getTranslationList});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: TestScaffold(
        localizationDelegate: localizationDelegate,
        getTranslationList: getTranslationList,
      ),
      localizationsDelegates: [
        localizationDelegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('hu'),
      ],
    );
  }
}
