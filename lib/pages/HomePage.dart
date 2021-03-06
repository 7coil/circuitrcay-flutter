import 'package:circuitrcay/class/User.dart';
import 'package:circuitrcay/pages/LoginPage.dart';
import 'package:circuitrcay/tabs/MachinesTab.dart';
import 'package:circuitrcay/tabs/MainTab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.userData}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final User userData;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    this.controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  void handleMenu(String option) {
    if (option == 'logout') {
      areYouSureJen();
    } else if (option == 'org') {
      showOrganisationMessage();
    } else if (option == 'notify') {
      notify();
    }
  }

  void showOrganisationMessage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.userData.accountWelcomeTitle),
            content: Text(widget.userData.accountWelcomeText),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  // Close dialog
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void areYouSureJen() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Log off?'),
            content: Text('Circuit will be sad.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  // Close dialog
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Log Off'),
                onPressed: () {
                  // Close dialog
                  Navigator.of(context).pop();
                  // Log out
                  logout();
                },
              )
            ],
          );
        });
  }

  void logout() {
    // _scaffoldKey.currentState.showSnackBar(SnackBar(
    //   content: Text('Logging off...'),
    // ));
    widget.userData.logout();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  void notify() {}

  TabBarView getTabBarView(var tabs) {
    return TabBarView(
      children: tabs,
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("CircuitRCAY"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: handleMenu,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'org',
                child: Text('My Organisation'),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log Out of ' + widget.userData.accountName),
              ),
            ],
          )
        ],
        bottom: TabBar(
          tabs: <Widget>[
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.local_laundry_service))
          ],
          controller: controller,
        ),
      ),
      body: getTabBarView(
        <Widget>[
          MainTab(userData: widget.userData),
          MachinesTab(userData: widget.userData),
        ],
      ),
    );
  }
}
