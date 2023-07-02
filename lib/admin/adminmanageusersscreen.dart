// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/admin/admincreateuserscreen.dart';

class ManageUserScreen extends StatefulWidget {
  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String selectedRole = 'All Users';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        title: Text(
          'Manage Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(children: [
        Container(
          width: 200,
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedRole,
            alignment: Alignment.center,
            onChanged: (String? newValue) {
              setState(() {
                selectedRole = newValue ?? 'All Users'; // Update selected role
              });
            },
            items: <String>['All Users', 'Admin', 'Technician', 'Manager']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: db.collection('User').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> usersWidget = [];
                List<DocumentSnapshot> sortedUsers = snapshot.data!.docs;

                sortedUsers.sort((a, b) => (a['firstName'] as String)
                    .compareTo(b['firstName'] as String));

                for (DocumentSnapshot userSnapshot in sortedUsers) {
                  // filter according to user types
                  if ((selectedRole == 'All Users' ||
                          userSnapshot['role'] == selectedRole) &&
                      userSnapshot['role'] != 'Customer') {
                    usersWidget.add(
                      ListTile(
                        title: Row(
                          children: [
                            Text(
                              userSnapshot['firstName'] +
                                  ' ' +
                                  userSnapshot['lastName'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Role: ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Text(
                              userSnapshot['role'],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetails(
                                username: userSnapshot['username'],
                                firstName: userSnapshot['firstName'],
                                lastName: userSnapshot['lastName'],
                                role: userSnapshot['role'],
                                contact: userSnapshot['contact'],
                                address: userSnapshot['address'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }
                return ListView(
                  children: usersWidget,
                );
              } else {
                return Center(
                  child: Text('No user found'),
                );
              }
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green.shade700,
        onPressed: () {
          // Redirect to the CreateUserScreen to create a new user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateUserScreen(),
            ),
          );
        },
      ),
    );
  }
}

class UserDetails extends StatefulWidget {
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String contact;
  final String address;

  UserDetails({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.contact,
    required this.address,
  });

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.role} Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade800,
        leading: IconTheme(
          data:
              IconThemeData(color: Colors.black), // Set the desired color here
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DataTable(
              columns: [
                DataColumn(
                  label: Text(
                    'Username',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '${widget.username}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'First Name',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${widget.firstName}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'Last Name',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${widget.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'Role',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${widget.role}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'Contact No',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${widget.contact}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Address",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              child: TextFormField(
                style: TextStyle(fontSize: 16, color: Colors.black),
                maxLines: 6,
                initialValue: '${widget.address}',
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}