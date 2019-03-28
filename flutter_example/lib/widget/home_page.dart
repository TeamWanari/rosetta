import 'package:flutter/material.dart';
import 'package:flutter_example/util/translation.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(Translation.of(context).helloThere),
      ),
    );
  }
}
