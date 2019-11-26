import 'dart:convert';

import 'package:circuitrcay/class/Machines.dart';
import 'package:crypted_preferences/crypted_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

class User {
  int appUserId;
  String token;
  String accountName;
  String accountWelcomeTitle;
  String accountWelcomeText;
  double accountBalance;
  int accountCurrencyTypeID;
  String accountCurrencyUniCode;
  bool ok;
  List<Machine> machines = List<Machine>();

  User.fromJSON(Map<String, dynamic> keyValue) {
    ok = keyValue['Success'] == true;
    if (ok) {
      var data = keyValue['Data'];

      accountBalance = data['AccountBalance'];
      accountCurrencyTypeID = data['AccountCurrencyTypeID'];
      accountCurrencyUniCode = data['AccountCurrencyUniCode'];
      appUserId = data['AppUserId'];
      token = data['Token']['Value'];
      accountName = data['AccountName'];
      accountWelcomeTitle = data['AccountWelcomeTitle'];
      accountWelcomeText = data['AccountWelcomeText'];
    }
  }

  Future<void> updateBalance() async {
    final response = await http.post(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/ReconcileCards',
        headers: {'authorization': 'bearer $token'});

    var json = jsonDecode(response.body);

    if (json['Success'] == true) {
      this.accountBalance = json['Data']['AccountBalance'];
    }
  }

  Future<void> updateMachines() async {
    machines = await Machine.listMachines(token);
    print(machines);
  }

  Future<void> logout() async {
    LocalStorage storage = LocalStorage('data');
    await storage.ready;
    storage.setItem("userData", null);

    return;
  }

  static Future<User> getFromStorage() async {
    LocalStorage storage = LocalStorage('data');
    await storage.ready;
    var userDataJSON = storage.getItem('userData');

    // Return null if the user in storage doesn't exist.
    if (userDataJSON == null) {
      return null;
    }

    // Return the userdata
    var userDataDynamic = jsonDecode(userDataJSON);
    User userData = User.fromJSON(userDataDynamic);

    return userData;
  }
}

// {
// 	"AppUserId": 12345678,
// 	"Token": {
// 		"Value": "abcdefg",
// 		"Expires": null
// 	},
// 	"PrimaryLocation": "",
// 	"AccountBalance": 25.5,
// 	"InternalId": 1234,
// 	"ExternalKey": "abcdefg",
// 	"AccountName": "something@example.com",
// 	"AccountOperatorID": 2,
// 	"AccountMinimumPurchaseAmount": 5,
// 	"AccountLowBalanceIndicator": 5,
// 	"AccountCurrencyTypeID": 2,
// 	"AccountCurrencyUniCode": "00AB",
// 	"IsRoomViewAvailable": false,
// 	"AccountWelcomeTitle": "Welcome to CircuitRCAY",
// 	"AccountWelcomeText": "Please ensure that your internet service provider can even provide your internet feed with internet."
// }
