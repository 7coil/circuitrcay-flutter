import 'dart:convert';

import 'package:circuitapp/class/User.dart';
import 'package:circuitapp/pages/HomePage.dart';
import 'package:circuitapp/pages/LoginPage.dart';
import 'package:crypted_preferences/crypted_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LandingPage extends StatefulWidget {
  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  @override
  initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      runInitTasks();
    });
  }

  @protected
  Future runInitTasks() async {
    User userData = await User.getFromStorage();

    if (userData == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));

      return;
    }

    // Update the balance of the user
    userData.updateBalance();

    // Pass the user data to the Home Page.
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) =>
            HomePage(title: 'CircuitRCAY', userData: userData)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
      title: new Text("Loading..."),
    ));
  }
}
