// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/admin/createuserscreen.dart';

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
        backgroundColor: Colors.white,
        title: Text(
          'Manage Users',
          style: TextStyle(color: Colors.black),
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
                  if (selectedRole == 'All Users' ||
                      userSnapshot['role'] == selectedRole) {
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
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
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
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 33,
                ),
                Text(
                  '${widget.username}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),

            // start date
            Row(
              children: [
                Text(
                  'First Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 79,
                ),
                Text(
                  '${widget.firstName}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),

            // end date
            Row(
              children: [
                Text(
                  'Last Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 88,
                ),
                Text(
                  '${widget.lastName}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),

            // leave type
            Row(
              children: [
                Text(
                  'Role',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 72,
                ),
                Text(
                  '${widget.role}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),

            //
            Row(
              children: [
                Text(
                  'contact No',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 61,
                ),
                Text(
                  '${widget.contact}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Address",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
