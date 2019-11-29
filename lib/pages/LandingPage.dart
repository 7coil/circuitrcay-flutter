import 'package:circuitrcay/class/User.dart';
import 'package:circuitrcay/pages/HomePage.dart';
import 'package:circuitrcay/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LandingPage extends StatefulWidget {
  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  initState() {
    super.initState();

    // var initialisationSettingsAndroid = new AndroidInitializationSettings('ic_launcher_foreground');
    // var initialisationSettingsIOS = new IOSInitializationSettings();
    // var initialisationSettings = new InitializationSettings(initialisationSettingsAndroid, initialisationSettingsIOS);

    // flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // flutterLocalNotificationsPlugin.initialize(initialisationSettings, onSelectNotification: onSelectNotification);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      runInitTasks();
    });
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: Text('Hello world!'),
        content: Text('Welcome to the app!'),
      ),
    );
  }

  @protected
  Future runInitTasks() async {
    User userData = await User.getFromStorage();

    if (userData == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));

      return;
    }

    // Update the user before loading
    userData.updateBalance();
    userData.updateMachines();

    // Pass the user data to the Home Page.
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            HomePage(title: 'CircuitRCAY', userData: userData)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: Text("Loading..."),
    ));
  }
}
