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

  void initState() {
    super.initState();
    this._machines = widget.userData.machines;
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
        print(machine.name);
        String name = machine.name;
        String date = machine.estimatedCompletionTime.toString();
        widgets.add(
          Container(
            child: Text("$name, $date"),
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
