import 'package:flutter/material.dart';
import 'package:tracking_app/widget/projectList.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tracking_app/widget/register.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  void _login() async {
    final url = Uri.https(
        'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'registerUser.json');

    final response = await http.get(url);
    final Map<String, dynamic> users = json.decode(response.body);
    String tempUser = "";
    // Check if the entered username and password match any user in the database
    final user = users.values.firstWhere(
      (user) {
        if (user['username'] == _usernameController.text &&
            user['password'] == _passwordController.text) {
          tempUser = _usernameController.text;
        }
        return (user['username'] == _usernameController.text &&
            user['password'] == _passwordController.text);
      },
      orElse: () => null,
    );

    if (user != null) {
      print('Succesfully Login');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Succesfully Login')),
      );
      // Successful login, navigate to home screen or desired screen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return ProjectList(username: tempUser);
        },
      ));
    } else if (_passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      // Show a snackbar or display an error message for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return; // Exit the method if any field is empty
    } else {
      // Handle login failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account not registered')),
      );
      print('Failed to login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 21, 95, 174),
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 69, 117, 168),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/tracking.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                        'Username', Icons.person, _usernameController),
                    SizedBox(height: 10),
                    _buildTextField('Password', Icons.lock, _passwordController,
                        isPassword: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                         _login();
                      },
                      child: Text('Login'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Register(),
                            ),
                          );
                        },
                        child: Text('Don\'t have any account , please Register First')
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String labelText, IconData prefixIcon, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'The value must not be null or empty';
        }
        return null; // Return null to indicate that the input is valid
      },
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.blue,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.blue.withOpacity(0.7), width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
