import 'dart:convert';

import 'package:circuitapp/class/User.dart';
import 'package:circuitapp/pages/HomePage.dart';
import 'package:crypted_preferences/crypted_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _email = "";
  String _password = "";
  String _error = "";

  LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  void loginPressed() async {
    print("Login! " + _email + " " + _password);

    String password = _password;

    if (password.length > 64) {
      password = _password.substring(0, 64);
    }

    final response = await http.post(
        'https://laundrymachines.netlify.com/.netlify/functions/fetch/api/user/authenticate?email=$_email&password=$password');
    print(response.body);

    var json = jsonDecode(response.body);

    User userData = User.fromJSON(json);

    if (userData.ok) {
      var prefs = await Preferences.preferences(path: 'haseul');
      prefs.setString("userData", response.body);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              HomePage(title: 'CircuitRCAY', userData: userData)));
    } else {
      setState(() {
        _error = json['Message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to CircuitRCAY'),
      ),
      body: Container(
          padding: const EdgeInsets.all(32),
          child: ListView(
            children: <Widget>[
              Text("Welcome to CircuitRCAY"),
              TextField(
                controller: _emailFilter,
                decoration: new InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordFilter,
                decoration: new InputDecoration(
                  labelText: "Password",
                ),
                obscureText: true,
              ),
              RaisedButton(
                child: Text("Login"),
                onPressed: loginPressed,
              ),
              Text('$_error'),
            ],
          )),
    );
  }
}
