import 'package:barcode_scan/barcode_scan.dart';
import 'package:circuitrcay/class/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MainTab extends StatefulWidget {
  MainTab({Key key, this.userData}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final User userData;

  MainTabState createState() => MainTabState();
}

class MainTabState extends State<MainTab> {
  final TextEditingController _machineFilter = TextEditingController();

  String _balanceString = "";
  String _barcode;

  MainTabState() {
    _machineFilter.addListener(_machineListen);
  }

  void _machineListen() {
    String newBarcode = "";

    if (_machineFilter.text.isNotEmpty) {
      newBarcode = _machineFilter.text;
    }

    setState(() => this._barcode = newBarcode);

    print(this._barcode);
  }

  void initState() {
    super.initState();
    this._balanceString = widget.userData.accountBalance.toStringAsFixed(2);
  }

  void scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        this._machineFilter.text = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('The application does not have enough permissions to access your camera.'),
        ));
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    } on FormatException {
      // User pressed the back button. It's ok.
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Future<void> onRefresh() async {
    await widget.userData.updateBalance();
    await widget.userData.updateMachines();

    setState(() {
      this._balanceString = widget.userData.accountBalance.toStringAsFixed(2);
    });

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Reloaded page!'),
    ));
    return;
  }

  void activateMachine() async {
    try {
      await widget.userData.activateMachine(_barcode);
    } catch(e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Function topUp(int amount) {
    return () async {
      try {
        String url = await widget.userData.getPaymentURL(amount, "", true);
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Failed to launch $url"),
          ));
        }
      } catch(e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: <Widget>[
          Center(
            child: Column(
              // center the children
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Text("Balance"),
                  Expanded(child: Divider()),
                ]),
                Text(
                  "£$_balanceString",
                  style: TextStyle(fontSize: 60),
                ),
                SizedBox(height: 30),
                Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Text("Top Up"),
                  Expanded(child: Divider()),
                ]),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: topUp(5),
                        child: Text("£5"),
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        onPressed: topUp(10),
                        child: Text("£10"),
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        onPressed: topUp(20),
                        child: Text("£20"),
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        onPressed: topUp(50),
                        child: Text("£50"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Text("Activate Machines"),
                  Expanded(child: Divider()),
                ]),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: scan,
                        child: Text("Scan QR Code"),
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        onPressed: activateMachine,
                        child: Text("Activate Machine"),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: _machineFilter,
                  decoration: InputDecoration(
                    labelText: "Machine ID",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onRefresh: onRefresh,
    );
  }
}
