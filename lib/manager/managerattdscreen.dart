// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagerAttendancePage extends StatefulWidget {
  const ManagerAttendancePage({super.key});

  @override
  State<ManagerAttendancePage> createState() => _ManagerAttendancePageState();
}

class _ManagerAttendancePageState extends State<ManagerAttendancePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Manage Attendance',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('User').snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (userSnapshot.hasError) {
                  return Center(
                    child: Text('Error getting attendance'),
                  );
                } else if (userSnapshot.hasData) {
                  List<Widget> attdWidget = [];
                  return FutureBuilder<void>(
                    future: Future.forEach(
                      userSnapshot.data!.docs,
                      (userDoc) async {
                        String docId = userDoc.id;

                        // retrieve attendance details
                        QuerySnapshot attdSnapshot = await db
                            .collection('User')
                            .doc(docId)
                            .collection('Attendance')
                            .get();

                        if (attdSnapshot.docs.isNotEmpty) {
                          for (DocumentSnapshot attdDoc in attdSnapshot.docs) {
                            attdWidget.add(
                              ListTile(
                                title: Text(
                                  userDoc['firstName'],
                                  style: TextStyle(color: Colors.black),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AttdDetails(
                                        firstName: userDoc['firstName'],
                                        lastName: userDoc['lastName'],
                                        checkIn: attdDoc['checkIn'],
                                        checkOut: attdDoc['checkOut'],
                                        attdDocumentId: attdDoc.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }
                      },
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (attdWidget.isNotEmpty) {
                          return ListView(
                            children: attdWidget,
                          );
                        } else {
                          return Center(
                            child: Text('No Attendance Found'),
                          );
                        }
                      }
                    },
                  );
                } else {
                  return Center(
                    child: Text('No users found'),
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

class AttdDetails extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String checkIn;
  final String checkOut;
  final String attdDocumentId;

  AttdDetails({
    required this.firstName,
    required this.lastName,
    required this.checkIn,
    required this.checkOut,
    required this.attdDocumentId,
  });

  @override
  _AttdDetailsState createState() => _AttdDetailsState();
}

class _AttdDetailsState extends State<AttdDetails> {
  late bool isButtonClicked = false;

  @override
  void initState() {
    super.initState();
  }

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
      body: SingleChildScrollView(),
    );
  }
}
