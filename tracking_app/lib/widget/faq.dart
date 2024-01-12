import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 21, 95, 174),
      appBar: AppBar(
        title: Text('FAQ'),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 69, 117, 168), 
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FAQItem(
              question: 'How to register an account?',
              answer: 'To register an account, go to the main page and click on the "Register" button.',
            ),
            FAQItem(
              question: 'How to log in?',
              answer: 'On the login page, enter your username and password, and then click the "Login" button.',
            ),
            FAQItem(
              question: 'How to register a project?',
              answer: 'Navigate to the "ProjectList" page and fill in the required information.',
            ),
            FAQItem(
              question: 'How to register an activity?',
              answer: 'After logging in, go to the "ProjectDetail" page and provide the necessary details.',
            ),
            FAQItem(
              question: 'How to update activity status?',
              answer: 'Visit the "ProjectDetail" page and select the activity you want to update.',
            ),
            FAQItem(
              question: 'How to view project progress?',
              answer: 'Navigate to the "ProjectDetail" on the top page to see the overall progress of your projects.',
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, 
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }
}