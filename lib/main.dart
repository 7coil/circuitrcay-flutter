import 'package:circuitapp/pages/LandingPage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'CircuitRCAY',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LandingPage());
  }
}
