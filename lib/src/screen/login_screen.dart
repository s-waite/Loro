import 'package:flutter/material.dart';
import 'package:loro/src/utility/password.dart' as pw;
import 'package:loro/main.dart';
import 'package:loro/src/entity/user.dart';
import 'package:loro/src/screen/home_screen.dart';

// Create a Form widget.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";

  void checkLoginCredentials(String username, String password) {}

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            // The validator receives the text that the user has entered.
            onChanged: (value) => _username = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
          ),
          TextFormField(
            onChanged: (value) => _password = value,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  bool userExists = false;
                  User? user = await Loro.of(context)
                      .db
                      .userDao
                      .findUserByUsername(_username);
                  userExists = (user != null) ? true : false;
                  bool validLogin = false;
                  if (userExists) {
                    validLogin = await pw.verifyPasswordHashedSalted(
                        _username, _password, Loro.of(context).db);
                  }

                  if (!validLogin) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          icon: Icon(Icons.error),
                          title: Text("Error Logging In"),
                          content: Text(
                              "Please check your credentials and try again."),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("Ok"))
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.pushNamed(context, '/second');
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
