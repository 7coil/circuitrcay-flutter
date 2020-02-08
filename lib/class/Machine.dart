import 'dart:convert';

import 'package:http/http.dart' as http;

class Machine {
  String machineID;
  int machineInUseID;
  bool available;
  String statusDescription;
  String category;
  DateTime estimatedCompletionTime;
  int highSuggestedCreditAmount;
  int lowSuggestedCreditAmount;
  String make;
  String model;
  String name;
  int status;
  String statusText;
  String accountExternalKey;
  String locationID;
  String operatorExternalKey;

  Machine.fromJSON(Map<String, dynamic> keyValue) {
    String estimatedCompletionTimeString = keyValue['EstimatedCompletionTime'];

    // Dart can only take 6 digit fraction of a second.
    // Substring 2 removes (Z) and (4).
    // 2019-11-19T15:18:00.0685314Z
    if (estimatedCompletionTimeString.length > 0) {
      estimatedCompletionTimeString = estimatedCompletionTimeString.substring(0, estimatedCompletionTimeString.length - 2);
      estimatedCompletionTime = DateTime.parse(estimatedCompletionTimeString);
    } else {
      estimatedCompletionTime = null;
    }

    machineID = keyValue['MachineId'];
    machineInUseID = keyValue['MachineInUseID'];
    available = keyValue['Available'];
    statusDescription = keyValue['StatusDescription'];
    category = keyValue['Category'];
    
    highSuggestedCreditAmount = keyValue['HighSuggestedCreditAmount'];
    lowSuggestedCreditAmount = keyValue['LowSuggestedCreditAmount'];
    make = keyValue['Make'];
    model = keyValue['Model'];
    name = keyValue['Name'];
    status = keyValue['Status'];
    statusText = keyValue['StatusText'];
    accountExternalKey = keyValue['AccountExternalKey'];
    locationID = keyValue['LocationId'];
    operatorExternalKey = keyValue['OperatorExternalKey'];
  }

  static Future<List<Machine>> listMachines(String token) async {
    final response = await http.get(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/LaundryStatus',
        headers: {'authorization': 'bearer $token'});

    var json = jsonDecode(response.body);

    if (json['Success'] == true) {
      List<Machine> list = (json['Data'] as List)
        .map((e) => Machine.fromJSON(e))
        .toList();

      // list.add(Machine.fromJSON(jsonDecode('{ "MachineId": "ABCDEFGH", "MachineInUseID": 0, "Available": true, "StatusDescription": "Available", "Category": "Washing Machines", "EstimatedCompletionTime": "2019-11-19T15:18:00.0685314Z", "HighSuggestedCreditAmount": 800, "LowSuggestedCreditAmount": 10, "Make": "Townsend Corporation", "Model": "Townsend 4000", "Name": "Test Washer", "Status": 1, "StatusText": "Available", "AccountExternalKey": "ABCDEFGH", "LocationId": "ABCDEFGH", "OperatorExternalKey": "ABCDEFGH", "rcayTimeRemaining": null }')));

      return list;
    } else {
      return List<Machine>();
    }
  }

  static Future<void> activateMachine(String token, String id) async {
    final response = await http.post(
      'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/CreateVirtualCard?machineId=$id',
      headers: {'authorization': 'bearer $token'});
    
    var json = jsonDecode(response.body);

    if (json['Success'] == true) {
      // Success!
    } else if (json['Success'] == false && json['Message'] == 'Authentication Failed') {
      throw('Machine ID Not Found');
    }
  }
}
