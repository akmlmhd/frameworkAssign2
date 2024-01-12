import 'package:flutter/material.dart';
import 'package:tracking_app/models/project.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddProject extends StatefulWidget {
  final String username;
  const AddProject({super.key, required this.username});

  @override
  State<AddProject> createState() {
    return _AddProjectState();
  }
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredDesc = '';
  var _enteredProsta = 'Incomplete';
  DateTime _dueDate = DateTime.now();
  var _isSending = false;

  void _saveProject() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });
      _formKey.currentState!.save();
      final url = Uri.https(
          'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
          'UserData/${widget.username}/project.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'description': _enteredDesc,
            'projectstatus': _enteredProsta,
            'dueDate': _dueDate.toIso8601String(),
          },
        ),
      );
      //check the data and status code
      print(response.body);
      print(response.statusCode);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully Register Project'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final Map<String, dynamic> resData = json.decode(response.body);

      //check the context for widget is null
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(Project(
        id: resData['name'],
        name: _enteredName,
        description: _enteredDesc,
        prosta: _enteredProsta,
        dueDate: _dueDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 118, 199, 185),
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Project',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Project Name',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 58, 70, 94),
                  )),
              validator: (value) {
                if (value == null || value.trim().length <= 1) {
                  return 'Must not null';
                }
                return null;
              },
              onSaved: (value) {
                _enteredName = value!;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Project Description',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 58, 70, 94),
                  )),
              validator: (value) {
                if (value == null || value.trim().length <= 1) {
                  return 'Must not null';
                }
                return null;
              },
              onSaved: (value) {
                _enteredDesc = value!;
              },
            ),
             SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Project Status',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 58, 70, 94),
                  )),
              initialValue: _enteredProsta,
              validator: (value) {
                if (value == null || value.trim().length <= 1) {
                  return 'Must not null';
                }
                return null;
              },
              onSaved: (value) {
                _enteredProsta = value!;
              },
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text('Due Date:'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy').format(_dueDate.toLocal()),
                style: TextStyle(fontSize: 20.0, color: Colors.black),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _dueDate) {
                  setState(() {
                    _dueDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isSending ? null : _saveProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 55, 114, 56),
              ),
              child: _isSending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Add Project'),
            ),
          ],
        ),
      ),
    );
  }
}
