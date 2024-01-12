import 'package:flutter/material.dart';
import 'login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _signUp() async {
    try {
      if (_emailController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        // Show a snackbar or display an error message for empty fields
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all fields')),
        );
        return; // Exit the method if any field is empty
      }

      final url = Uri.https(
        'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'registerUser.json',
      );

      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': _emailController.text,
            'username': _usernameController.text,
            'password': _passwordController.text,
          },
        ),
      );

      if (response.statusCode == 200) {
        print('User registered successfully');
        print(response.body);
        
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Succesfully Register')),
      );

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return Login();
          },
        ));
      } else {
        print('Failed to register user');
        // Handle registration failure
        // Show a snackbar or display an error message
      }
    } catch (error) {
      print('Error during registration: $error');
      // Handle other errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 21, 95, 174),
      appBar: AppBar(
        title: Text('Register'),
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
                    SizedBox(height: 10),
                    _buildTextField('Email', Icons.email, _emailController),
                    SizedBox(height: 10),
                    _buildTextField( 'Username', Icons.person, _usernameController),
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
                        _signUp();
                      },
                      child: Text('Register'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );
                        },
                        child: Text('Already have an account , please Log In')
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
