import 'package:circuitapp/class/User.dart';
import 'package:flutter/material.dart';

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

  void initState() {
    super.initState();
    balanceString = widget.userData.accountBalance.toStringAsFixed(2);
  }

  Future<void> onRefresh() async {
    print('Refresh!');
    await widget.userData.updateBalance();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Updated balance.'),
    ));
    return;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView(
        children: <Widget>[
          Center(
            child: Column(
              // center the children
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text("£$balanceString")],
            ),
          )
        ],
      ),
      onRefresh: onRefresh,
    );
  }
}
