import 'dart:convert';
import 'dart:io';

import 'package:circuitrcay/class/Machine.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  static Future<User> fromCredentials(String username, String password) async {
    if (password.length > 64) {
      password = password.substring(0, 64);
    }

    username = Uri.encodeQueryComponent(username);
    password = Uri.encodeQueryComponent(password);

    final response = await http.post(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/authenticate?email=$username&password=$password');

    var json = jsonDecode(response.body);

    User user = User.fromJSON(json);

    if (user.ok) {
      final file = await _localFile;
      await file.writeAsString(response.body);

      return user;
    } else {
      throw(json['Message']);
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

  Future<String> getPaymentURL(int amount, String promotionalCode, bool acceptCreditAndDebit) async {
    promotionalCode = Uri.encodeQueryComponent(promotionalCode);

    final response = await http.post(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/RequestPurchase?Amount=$amount&PromotionCode=$promotionalCode&billingDirect=$acceptCreditAndDebit',
        headers: {'authorization': 'bearer $token'});

    var json = jsonDecode(response.body);

    if (json['Success'] == true) {
      return json['Data']['PaymentURL'];
    } else {
      throw json['Message'];
    }
  }

  Future<void> updateMachines() async {
    machines = await Machine.listMachines(token);
    print(machines);
  }

  Future<void> activateMachine(String id) async {
    await Machine.activateMachine(token, id);
    await this.updateMachines();
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    File file = File('$path/data.json');

    if (!file.existsSync()) await file.writeAsString("");

    return file;
  }

  Future<void> logout() async {
    final file = await _localFile;
    await file.writeAsString("");

    return;
  }

  static Future<User> getFromStorage() async {
    final file = await _localFile;
    String userDataJSON = await file.readAsString();

    // Return null if the user in storage doesn't exist.
    if (userDataJSON == "") {
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
