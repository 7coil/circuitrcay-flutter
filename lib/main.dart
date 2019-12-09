import 'package:circuitrcay/class/User.dart';
import 'package:circuitrcay/pages/HomePage.dart';
import 'package:circuitrcay/pages/LoginPage.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    User userData = await User.getFromStorage();
    if (userData != null) {
      await userData.updateBalance();
      await userData.updateMachines();
    }
    runApp(MyApp(userData: userData,));
}

class MyApp extends StatelessWidget {
  final User userData;
  MyApp({Key key, this.userData}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'CircuitRCAY',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: userData == null ? LoginPage() : HomePage(userData: userData,));
  }
}
