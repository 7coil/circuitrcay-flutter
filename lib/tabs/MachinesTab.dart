import 'dart:async';

import 'package:circuitrcay/class/Machine.dart';
import 'package:circuitrcay/class/User.dart';
import 'package:flutter/material.dart';

class MachinesTab extends StatefulWidget {
  MachinesTab({Key key, this.userData}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final User userData;

  MachinesTabState createState() => MachinesTabState();
}

class MachinesTabState extends State<MachinesTab> {
  List<Machine> _machines = [];
  Map<Machine, String> _remaining = Map<Machine, String>();
  Timer _everySecond;

  void initState() {
    super.initState();
    this._machines = widget.userData.machines;
    redoCountdown();
    this._everySecond = Timer.periodic(Duration(milliseconds: 20), (Timer t) {
      redoCountdown();
    });
  }

  @override
  void dispose() {
    this._everySecond?.cancel();
    super.dispose();
  }

  void redoCountdown() {
    setState(() {
      DateTime now = DateTime.now();
      Map<Machine, String> map = Map<Machine, String>();
      this._machines
        .forEach((Machine machine) {
          if (machine.estimatedCompletionTime == null) {
            map[machine] = "Completed!";
          } else {
            Duration difference = machine.estimatedCompletionTime.difference(now);

            if (difference.isNegative) {
              map[machine] = "Completed!";
            } else {
              map[machine] = machine.estimatedCompletionTime.difference(now).toString();
            }
          }
        });
      _remaining = map;
    });
  }

  Future<void> onRefresh() async {
    await widget.userData.updateMachines();

    setState(() {
      this._machines = widget.userData.machines;
    });

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Reloaded page!'),
    ));
    return;
  }

  List<Widget> generateMachines() {
    List<Widget> widgets = [];

    this._machines
      .forEach((Machine machine) {
        String name = machine.name;
        String remaining = _remaining[machine];
        widgets.add(
          Container(
            child: Text("$name, $remaining"),
          )
        );
      });

    return widgets;
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
              children: generateMachines(),
            ),
          ),
        ],
      ),
      onRefresh: onRefresh,
    );
  }
}
