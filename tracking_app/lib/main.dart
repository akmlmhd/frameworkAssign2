import 'package:flutter/material.dart';
import 'package:tracking_app/widget/login.dart';
import 'package:tracking_app/widget/register.dart';
import 'widget/faq.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TrackingPage(),
    );
  }
}

class TrackingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 21, 95, 174),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Tracking App'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 69, 117, 168),
        leading: IconButton(
          icon: Icon(Icons.question_answer),
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FAQPage(), 
                ),
              );
          }
          ),
      ),
      body: Container(
        child: FirstPage(), //content First page
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/tracking.jpg', 
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Text(
            'My Tracking App',
            style: TextStyle(fontSize: 30,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.white,
              ),
          ),
          SizedBox(height: 10),
          Text(
            '\"Track Project Professionally"',
            style: TextStyle(fontSize: 25,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.white,
              ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Login(), 
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 66, 182, 48), // Background color
              onPrimary: Colors.white, // Text color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
            ),
            child: Text(
              'Login',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Register(), 
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 33, 153, 159), // Background color
              onPrimary: Colors.white, // Text color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
            ),
            child: Text(
              'Register',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
