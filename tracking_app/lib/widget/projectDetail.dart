import 'package:flutter/material.dart';
import 'package:tracking_app/models/project.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectDetails extends StatefulWidget {
  final String username;
  final Project project;

  ProjectDetails({required this.project, required this.username});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  final _formKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  var _enteredActi = '';
  var _enteredStat = 'Incomplete';
  String _updatedActivityName = '';
  String _updatedActivityStat = '';
  List<ProjectActivity> _projectAct = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  void _loadActivity() async {
    final url = Uri.https(
        'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'UserData/${widget.username}/project/${widget.project.id}/activities.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');

      //check if no records in firebase, terminate the program here
      if (response.body == 'null') {
        //disable _isLoading
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic>? listData = json.decode(response.body);

      if (listData != null) {
        final List<ProjectActivity> _loadedActivity = [];

        for (final item in listData.entries) {
          print('Item: $item');
          _loadedActivity.add(
            ProjectActivity(
              id: item.key,
              name: item.value['name'],
              status: item.value['status'],
            ),
          );
        }

        setState(() {
          _projectAct = _loadedActivity;
          _isLoading = false;
        });
      } else {
        print('Response body is not in the expected format.');
      }
    } else {
      print('Failed to load activities. ${response.statusCode}');
    }
  }

  void _addact() async {
    final newActi = await showDialog<ProjectActivity>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Activity'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Activity Name',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 58, 70, 94),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredActi = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Activity Progress',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 58, 70, 94),
                      )),
                  initialValue: _enteredStat,
                  validator: (value) {
                    if (value == null) {
                      return 'Must not null';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredStat = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 12, 138, 64),
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveActivity();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 12, 138, 64),
              ),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
    //_loadActivity();
    if (newActi == null) {
      return;
    }

    setState(() {
      _projectAct.add(newActi);
    });
  }

  void _deleteActivity(ProjectActivity activity) async {
    final url = Uri.https(
      'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
      'UserData/${widget.username}/project/${widget.project.id}/activities/${activity.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      print('Failed to delete item from the database. ${response.statusCode}');
    } else {
      print('Successfully deleted');

      setState(() {
        _projectAct.remove(activity);
      });
    }
  }

  void _showDeleteConfirmationDialog(ProjectActivity activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Activity"),
          content: Text("Are you sure you want to delete this activity?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteActivity(activity);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateActivity(ProjectActivity activity) async {
    _updatedActivityName = activity.name;
    _updatedActivityStat = activity.status;

    await showDialog<ProjectActivity>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Activity'),
          content: Form(
            key: _updateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _updatedActivityName,
                  decoration: InputDecoration(
                    labelText: 'New Activity Name',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 58, 70, 94),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Must not be empty';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _updatedActivityName = value!;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _updatedActivityStat,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {
                    setState(() {
                      _updatedActivityStat = newValue!;
                    });
                  },
                  items: <String>['Complete', 'Incomplete']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 12, 138, 64),
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveUpdatedActivity(activity);
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 12, 138, 64),
              ),
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _saveUpdatedActivity(ProjectActivity activity) async {
    if (_updateFormKey.currentState!.validate()) {
      _updateFormKey.currentState!.save();

      final url = Uri.https(
        'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'UserData/${widget.username}/project/${widget.project.id}/activities/${activity.id}.json',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _updatedActivityName,
            'status': _updatedActivityStat,
          },
        ),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        _loadActivity(); // Reload activities after updating
      }
    }
  }

  double calculateCompletePercentage() {
    if (_projectAct.isEmpty) {
      return 0.0; // Return 0 if there are no activities
    }

    int completeCount = 0;

    for (ProjectActivity activity in _projectAct) {
      if (activity.status == 'Complete') {
        completeCount++;
      }
    }

    double percentage = (completeCount / _projectAct.length) * 100;
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No Activity added yet'));

    //add for progress status
    if (_isLoading) {
      content = const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ));
    }

    if (_projectAct.isNotEmpty) {
      content = Expanded(
        child: ListView.builder(
          itemCount: _projectAct.length,
          itemBuilder: (ctx, index) => Card(
            color: Color.fromARGB(255, 124, 220, 215),
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _projectAct[index].name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        _projectAct[index].status,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          _updateActivity(_projectAct[index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(_projectAct[index]);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 69, 117, 168),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/blue.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
                color: Color.fromARGB(233, 168, 226, 212),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.project.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 43, 118, 94), // Customize the background color
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          'Project Progress: ${calculateCompletePercentage().toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white, // for better visibility
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(233, 163, 204, 224),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    'Activities:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 5),
              content,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 67, 95, 85),
        onPressed: () {
          _addact();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
        'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'UserData/${widget.username}/project/${widget.project.id}/activities.json',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredActi,
            'status': _enteredStat,
          },
        ),
      );

      print(response.body);
      print(response.statusCode);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Succesfully Register Activity'),
        behavior: SnackBarBehavior.floating
        ),
      );

      final Map<String, dynamic> resData = json.decode(response.body);

      //check the context for widget is null
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(ProjectActivity(
        id: resData['name'],
        name: _enteredActi,
        status: _enteredStat,
      ));
    }
  }
}
