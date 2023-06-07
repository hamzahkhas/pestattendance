// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Manage Leaves',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('User').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (userSnapshot.hasError) {
            return Center(
              child: Text('Error fetching users'),
            );
          } else if (userSnapshot.hasData) {
            List<Widget> leaveWidgets = [];
            return FutureBuilder<void>(
              future: Future.forEach(
                userSnapshot.data!.docs,
                (userDoc) async {
                  String docId = userDoc.id;

                  QuerySnapshot leaveSnapshot = await db
                      .collection('User')
                      .doc(docId)
                      .collection('Leaves')
                      .orderBy('applicationDate', descending: true)
                      .get();

                  if (leaveSnapshot.docs.isNotEmpty) {
                    // Process the leaveSnapshot data
                    for (DocumentSnapshot leaveDoc in leaveSnapshot.docs) {
                      leaveWidgets.add(
                        ListTile(
                          title: Row(
                            children: [
                              Text(
                                userDoc['firstName'],
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                width: 100,
                              ),
                              Text(leaveDoc['leaveType']),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Application Date: ',
                                style: TextStyle(color: Colors.black87),
                              ),
                              Text(
                                leaveDoc['applicationDate'],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeaveDetails(
                                  firstName: userDoc['firstName'],
                                  applicationDate: leaveDoc['applicationDate'],
                                  startDate: leaveDoc['startDate'],
                                  endDate: leaveDoc['endDate'],
                                  noOfDays: leaveDoc['noOfDays'],
                                  leaveType: leaveDoc['leaveType'],
                                  leaveStatus: leaveDoc['leaveStatus'],
                                  leaveDescription:
                                      leaveDoc['leaveDescription'],
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
                  if (leaveWidgets.isNotEmpty) {
                    return ListView(
                      children: leaveWidgets,
                    );
                  } else {
                    return Center(
                      child: Text('No leaves found'),
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
    );
  }
}

class LeaveDetails extends StatefulWidget {
  final String firstName;
  final String applicationDate;
  final String leaveType;
  final String leaveStatus;
  final String leaveDescription;
  final String startDate;
  final String endDate;
  final String noOfDays;

  LeaveDetails({
    required this.firstName,
    required this.applicationDate,
    required this.leaveType,
    required this.leaveStatus,
    required this.leaveDescription,
    required this.startDate,
    required this.endDate,
    required this.noOfDays,
  });

  @override
  _LeaveDetailsState createState() => _LeaveDetailsState();
}

class _LeaveDetailsState extends State<LeaveDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leave Details',
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
                  'First Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 33,
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
            Row(
              children: [
                Text(
                  'Application Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 33,
                ),
                Text(
                  '${widget.applicationDate}',
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
                  'Start Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 79,
                ),
                Text(
                  '${widget.startDate}',
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
                  'End Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 88,
                ),
                Text(
                  '${widget.endDate}',
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
                  'Leave Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 72,
                ),
                Text(
                  '${widget.leaveType}',
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
                  'Leave Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 61,
                ),
                Text(
                  '${widget.leaveStatus}',
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
                "Leave Description",
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
                initialValue: '${widget.leaveDescription}',
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
