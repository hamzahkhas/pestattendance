// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, sort_child_properties_last, prefer_interpolation_to_compose_strings, use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/admin/admincreateuserscreen.dart';
import 'package:url_launcher/url_launcher.dart';

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
        backgroundColor: Colors.blue.shade800,
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
            items: <String>['All Users', 'Technician', 'Manager']
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
                      userSnapshot['role'] != 'Customer' &&
                      userSnapshot['role'] != 'Admin') {
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
                                cardId: userSnapshot['nfcIdentifier'],
                                role: userSnapshot['role'],
                                contact: userSnapshot['contact'],
                                address: userSnapshot['address'],
                                id: userSnapshot.id,
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
  final String cardId;
  final String role;
  final String contact;
  String address;
  final String id;

  UserDetails({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.cardId,
    required this.contact,
    required this.address,
    required this.id,
  });

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: widget.address);
  }

  // confirmation to delete user
  void deleteUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this user forever?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Delete the leave from Firestore
                deleteUserFromFirestore();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // remove user from firebase
  void deleteUserFromFirestore() async {
    try {
      FirebaseFirestore.instance.collection('User').doc(widget.id).delete();
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      print('Error deleting leave: $e');
      // Show an error message or handle the error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.role} Details ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade800,
        leading: IconTheme(
          data:
              IconThemeData(color: Colors.black), // Set the desired color here
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => deleteUser(),
            icon: Icon(Icons.delete),
            color: Colors.white,
          )
        ],
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
                if (widget.role == 'Technician')
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Card ID',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.cardId}',
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
                      GestureDetector(
                        onTap: () {
                          launch(
                              'tel:${widget.contact}'); // Launch the phone app with the contact number
                        },
                        child: Text(
                          '${widget.contact}',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
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
              width: 300,
              margin: EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  launch(
                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.address)}');
                },
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  maxLines: 4,
                  initialValue: '${widget.address}',
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            // GestureDetector(
            //   onTap: () {
            //     // deleteUser();
            //   },
            //   child: Container(
            //     height: 50,
            //     width: 170,
            //     margin: EdgeInsets.only(top: 10),
            //     decoration: BoxDecoration(
            //       color: Colors.black87,
            //       borderRadius: const BorderRadius.all(
            //         Radius.circular(10),
            //       ),
            //     ),
            //     child: Center(
            //       child: Text(
            //         'Update Details',
            //         style: TextStyle(
            //             fontSize: 18, color: Colors.white, letterSpacing: 2),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
