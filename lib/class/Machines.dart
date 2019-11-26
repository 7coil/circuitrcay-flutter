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
    machineID = keyValue['machineId'];
    machineInUseID = keyValue['machineInUseID'];
    available = keyValue['available'];
    statusDescription = keyValue['statusDescription'];
    category = keyValue['category'];
    estimatedCompletionTime = keyValue['estimatedCompletionTime'];
    highSuggestedCreditAmount = keyValue['highSuggestedCreditAmount'];
    lowSuggestedCreditAmount = keyValue['lowSuggestedCreditAmount'];
    make = keyValue['make'];
    model = keyValue['model'];
    name = keyValue['name'];
    status = keyValue['status'];
    statusText = keyValue['statusText'];
    accountExternalKey = keyValue['accountExternalKey'];
    locationID = keyValue['locationId'];
    operatorExternalKey = keyValue['operatorExternalKey'];
  }

  static Future<List<Machine>> listMachines(String token) async {
    final response = await http.get(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/LaundryStatus',
        headers: {'authorization': 'bearer $token'});

    var json = jsonDecode(response.body);

    if (json['Success'] == true) {
      return (json['Data'] as List)
        .map((e) => Machine.fromJSON(e))
          .toList();
    } else {
      return List<Machine>();
    }
  }
}
