import 'package:barcode_scan/barcode_scan.dart';
import 'package:circuitrcay/class/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Balance extends StatefulWidget {
  Balance({Key key, this.userData}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final User userData;

  BalanceState createState() => BalanceState();
}

class BalanceState extends State<Balance> {
  String balanceString = "";
  String barcode;

  void initState() {
    super.initState();
    balanceString = widget.userData.accountBalance.toStringAsFixed(2);
  }

 Future scan() async {
   try {
     String barcode = await BarcodeScanner.scan();
     setState(() => this.barcode = barcode);
   } on PlatformException catch (e) {
     if (e.code == BarcodeScanner.CameraAccessDenied) {
       setState(() {
         this.barcode = 'The user did not grant the camera permission!';
       });
     } else {
       setState(() => this.barcode = 'Unknown error: $e');
     }
   } on FormatException {
     setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
   } catch (e) {
     setState(() => this.barcode = 'Unknown error: $e');
   }
 }

  Future<void> onRefresh() async {
    await widget.userData.updateBalance();
    await widget.userData.updateMachines();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Reloaded page!'),
    ));
    return;
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
                Text(
                  "Your balance is:"
                ),
                Text(
                  "£$balanceString",
                  style: TextStyle(
                    fontSize: 60
                  ),
                ),
                Text(
                  "$barcode"
                ),
                Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: scan,
                      child: Text("Scan"),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
      onRefresh: onRefresh,
    );
  }
}
