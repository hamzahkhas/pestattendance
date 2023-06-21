// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagerAttd extends StatefulWidget {
  const ManagerAttd({super.key});

  @override
  State<ManagerAttd> createState() => _ManagerAttdState();
}

class _ManagerAttdState extends State<ManagerAttd> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Manage Attd',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
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
                    if (userSnapshot['role'] == 'Technician') {
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
                                    firstName: userSnapshot['firstName'],
                                    lastName: userSnapshot['lastName'],
                                    id: userSnapshot.id),
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
        ],
      ),
    );
  }
}

class UserDetails extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String id;

  UserDetails({
    required this.firstName,
    required this.lastName,
    required this.id,
  });

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final FirebaseFirestore db2 = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Details',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        'First Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '${widget.firstName}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            'Last Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Attendance History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: StreamBuilder<QuerySnapshot>(
                      // fetch the user details
                      stream: db2
                          .collection('User')
                          .doc(widget.id)
                          .collection("Attendance")
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (userSnapshot.hasError) {
                          return Center(
                            child: Text('Error fetching users'),
                          );
                        } else if (userSnapshot.hasData) {
                          final documents = userSnapshot.data!.docs;

                          if (documents.isEmpty) {
                            return Center(
                              child: Text('No leaves found'),
                            );
                          }

                          return Container(
                            height: 1000,
                            width: double.infinity,
                            child: ListView.builder(
                                itemCount: documents.length,
                                itemBuilder: (context, index) {
                                  final sample = documents[index];

                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          sample.id,
                                          style: TextStyle(color: Colors.black),
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AttdInfo(
                                                  attdDocId: sample.id,
                                                  checkIn: sample['checkIn'],
                                                  checkOut: sample['checkOut'],
                                                )),
                                      );
                                    },
                                  );
                                }),
                          );
                        } else {
                          return Center(
                            child: Text('No users found'),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttdInfo extends StatefulWidget {
  final String attdDocId;
  final String checkIn;
  final String checkOut;

  AttdInfo(
      {required this.attdDocId, required this.checkIn, required this.checkOut});

  @override
  _AttdInfoState createState() => _AttdInfoState();
}

class _AttdInfoState extends State<AttdInfo> {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.attdDocId,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: IconTheme(
          data: IconThemeData(color: Colors.black),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'Attendance Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      widget.attdDocId,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
                          'Check In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          widget.checkIn,
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
                          'Check Out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          widget.checkOut,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
