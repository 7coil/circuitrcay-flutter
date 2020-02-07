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

      accountBalance = double.parse(data['AccountBalance'].toString());
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
    // Circuit Managed Laundry Systems DO NOT take in passwords longer than 64 characters.
    // Any characters past the 64th char are discarded.
    if (password.length > 64) {
      password = password.substring(0, 64);
    }

    // Encode the username and password, so we can make a POST request
    username = Uri.encodeQueryComponent(username);
    password = Uri.encodeQueryComponent(password);

    // Perform the request
    final response = await http.post(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/authenticate?email=$username&password=$password');

    // Parse the body, and create the user
    var json = jsonDecode(response.body);
    User user = User.fromJSON(json);

    // If the request returns OK, our body can be saved to the file
    // Otherwise, return the error
    if (user.ok) {
      // Get a reference to the 'data.json' file, and write our JSON into the file
      final file = await _localFile;
      await file.writeAsString(response.body);

      // Return the new user
      return user;
    } else {
      throw (json['Message']);
    }
  }

  Future<void> updateBalance() async {
    // Make a post request with our token to update our balance
    final response = await http.post(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/ReconcileCards',
        headers: {'authorization': 'bearer $token'});

    // Parse the body
    var json = jsonDecode(response.body);

    // Update the balance of the user
    if (json['Success'] == true) {
      this.accountBalance =
          double.parse(json['Data']['AccountBalance'].toString());
    }
  }

  Future<String> getPaymentURL(
      int amount, String promotionalCode, bool acceptCreditAndDebit) async {
    promotionalCode = Uri.encodeQueryComponent(promotionalCode);

    // Make a post request to retrieve a new PayPal URL
    // Their query parameters cantDecide BetweenThe casing-theyre-going-to-use
    final response = await http.post(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/RequestPurchase?Amount=$amount&PromotionCode=$promotionalCode&billingDirect=$acceptCreditAndDebit',
        headers: {'authorization': 'bearer $token'});

    // Parse the body
    var json = jsonDecode(response.body);

    // If we were successful, return the URL
    // Otherwise, return the error message.
    if (json['Success'] == true) {
      return json['Data']['PaymentURL'];
    } else {
      throw json['Message'];
    }
  }

  Future<void> updateMachines() async {
    // Update the list of machines
    machines = await Machine.listMachines(token);
  }

  Future<void> activateMachine(String id) async {
    // After activating a machine, update the list of machines
    await Machine.activateMachine(token, id);
    await this.updateMachines();
  }

  static Future<String> get _localPath async {
    // Get a reference to the folder we can store local files in
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    // Get the reference to the file and folder we can store local files in
    final path = await _localPath;
    File file = File('$path/data.json');

    // If the file doesn't exist at the moment, write nothing
    if (!file.existsSync()) await file.writeAsString("");

    // Return the reference
    return file;
  }

  Future<void> logout() async {
    // Get a reference to the user file
    final file = await _localFile;

    // Overwrite with an empty string
    await file.writeAsString("");

    return;
  }

  static Future<User> getFromStorage() async {
    // Get a reference to the user file, and read the contents
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
