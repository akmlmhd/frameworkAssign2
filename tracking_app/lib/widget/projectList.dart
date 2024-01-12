import 'package:flutter/material.dart';
import 'package:tracking_app/main.dart';
import 'package:tracking_app/models/project.dart';
import 'projectDetail.dart';
import 'projectRegister.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProjectList extends StatefulWidget {
  final String username;

  const ProjectList({Key? key, required this.username}) : super(key: key);

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<Project> _project = [];
  final _updateFormKey = GlobalKey<FormState>();
  String _updatedName = '';
  String _updatedDescrip = '';
  String _updatedProsta = '';
  DateTime? _updatedDueDate;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  void _loadProject() async {
    final url = Uri.https(
        'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'UserData/${widget.username}/project.json');
    final response = await http.get(url);
    print('#debug projectList.dart');
    print(response.body);

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    print('#debug projectList.dart');
    print(listData);
    final List<Project> _loadedProject = [];
    for (final item in listData.entries) {
      _loadedProject.add(
        Project(
          id: item.key,
          name: item.value['name'],
          description: item.value['description'],
          prosta: item.value['projectstatus'],
          dueDate: item.value['dueDate'] != null
              ? DateTime.parse(item.value['dueDate'])
              : null,
        ),
      );
    }
    setState(() {
      _project = _loadedProject;
      _isLoading = false;
    });
  }

  void _addPro() async {
    final newProject = await showModalBottomSheet<Project>(
      context: context,
      builder: (BuildContext context) {
        return AddProject(username: widget.username);
      },
    );

    if (newProject == null) {
      return;
    }

    setState(() {
      _project.add(newProject);
    });
  }

  void _deleteProject(Project item) async {
    setState(() {
      _project.remove(item);
    });

    final url = Uri.https(
      'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
      'UserData/${widget.username}/project/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      print('Failed to delete item from the database.');
      setState(() {
        _project.add(item);
      });
    } else {
      print('Successfully Delete');
    }
  }

  void _showDeleteConfirmationDialog(Project project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Project"),
          content: Text("Are you sure you want to delete this project?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteProject(project);
                Navigator.of(context).pop();
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

  void _editProject(Project project) async {
    _updatedName = project.name;
    _updatedDescrip = project.description;
    _updatedProsta = project.prosta;
    _updatedDueDate = project.dueDate;

    await showDialog<Project>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Project'),
          content: Form(
            key: _updateFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _updatedName,
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                    _updatedName = value!;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  initialValue: _updatedDescrip,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
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
                    _updatedDescrip = value!;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _updatedProsta,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {
                    setState(() {
                      _updatedProsta = newValue!;
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
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Text('Due Date:'),
                    SizedBox(width: 8.0),
                    InkWell(
                      splashColor:
                          Colors.purple, 
                      child: Container(
                        padding: EdgeInsets.all(10.0), 
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(8.0), 
                          color: Color.fromARGB(255, 22, 125, 122), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2), 
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _updatedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _updatedDueDate) {
                              setState(() {
                                _updatedDueDate = picked;
                              });
                            }
                          },
                          child: Text(
                            'Change Date',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 12, 138, 64),
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveUpdatedProject(project);
                Navigator.of(context).pop();
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

  void _saveUpdatedProject(Project project) async {
    if (_updateFormKey.currentState!.validate()) {
      _updateFormKey.currentState!.save();

      final url = Uri.https(
        'tracking-7817d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'UserData/${widget.username}/project/${project.id}.json',
      );

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _updatedName,
            'description': _updatedDescrip,
            'projectstatus': _updatedProsta,
            'dueDate': _updatedDueDate?.toIso8601String(),
          },
        ),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        _loadProject();
      }
    }
  }

  String _getRemainingDays(Project project) {
    if (project.dueDate == null) {
      return 'No due date set';
    }

    final now = DateTime.now();
    final difference = project.dueDate!.difference(now).inDays;
    return 'Due in $difference days';
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No Project added yet'));

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      );
    }

    if (_project.isNotEmpty) {
      content = ListView.builder(
        itemCount: _project.length,
        itemBuilder: (ctx, index) => Card(
          color: Color.fromARGB(255, 124, 220, 215),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Container(
            width: double.infinity,
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetails(
                      project: _project[index],
                      username: widget.username,
                    ),
                  ),
                );
              },
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _project[index].name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    _project[index].description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 93, 29, 153),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      _project[index].prosta,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                ],
              ),
              subtitle: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 60, 104, 180), 
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      _project[index].dueDate != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(_project[index].dueDate!)
                          : 'No due date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.white, 
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 52, 132, 54),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      _getRemainingDays(_project[index]),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      _editProject(_project[index]);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(_project[index]);
                    },
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
        backgroundColor: Color.fromARGB(255, 69, 117, 168),
        title: const Text('My Projects'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackingPage(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/blue.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 22, 122, 119), 
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Welcome ${widget.username} !!!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(child: content),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 26, 77, 105),
        onPressed: () {
          _addPro();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
