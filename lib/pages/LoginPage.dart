import 'package:circuitrcay/class/User.dart';
import 'package:circuitrcay/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailFilter = TextEditingController();
  final TextEditingController _passwordFilter = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode loginFocusNode = FocusNode();

  String _email = "";
  String _password = "";

  LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  @override
  void dispose() {
    super.dispose();

    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    loginFocusNode.dispose();
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

  Future<void> loginPressed(BuildContext context) async {
    try {
      User user = await User.fromCredentials(_email, _password);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              HomePage(userData: user)));
    } catch (error) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to CircuitRCAY'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Container(
            child: ListView(
              padding: const EdgeInsets.all(32),
              children: <Widget>[
                Text("Welcome to CircuitRCAY"),
                TextFormField(
                  controller: _emailFilter,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  focusNode: emailFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (v) {
                    emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(passwordFocusNode);
                  },
                  inputFormatters: [
                    BlacklistingTextInputFormatter(RegExp('[\\t]'))
                  ],
                ),
                TextFormField(
                  controller: _passwordFilter,
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                  obscureText: true,
                  focusNode: passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (v) {
                    passwordFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(loginFocusNode);
                  },
                  inputFormatters: [
                    BlacklistingTextInputFormatter(RegExp('[\\t]'))
                  ],
                ),
                RaisedButton(
                  child: Text("Login"),
                  onPressed: () => loginPressed(context),
                  focusNode: loginFocusNode,
                ),
              ],
            )
          );
        },
      ),
    );
  }
}
