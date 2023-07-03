// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String selectedStatus = 'Pending';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          'Manage Leaves',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Container(
              width: 200,
              child: DropdownButton<String>(
                alignment: Alignment.center,
                isExpanded: true,
                value: selectedStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus =
                        newValue ?? 'Pending'; // Update selected role
                  });
                },
                items: <String>['Pending', 'Approved', 'Rejected']
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
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // fetch the user details
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

                        // retrieve the leave details
                        QuerySnapshot leaveSnapshot = await db
                            .collection('User')
                            .doc(docId)
                            .collection('Leaves')
                            .orderBy('applicationDate', descending: true)
                            .get();

                        if (leaveSnapshot.docs.isNotEmpty) {
                          // Process the leaveSnapshot data
                          for (DocumentSnapshot leaveDoc
                              in leaveSnapshot.docs) {
                            if (leaveDoc['leaveStatus'] == selectedStatus) {
                              leaveWidgets.add(
                                ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        userDoc['firstName'] +
                                            ' ' +
                                            userDoc['lastName'],
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        'Type: ',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      Text(
                                        leaveDoc['leaveType'],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LeaveDetails(
                                          firstName: userDoc['firstName'],
                                          lastName: userDoc['lastName'],
                                          applicationDate:
                                              leaveDoc['applicationDate'],
                                          startDate: leaveDoc['startDate'],
                                          endDate: leaveDoc['endDate'],
                                          noOfDays: leaveDoc['noOfDays'],
                                          leaveType: leaveDoc['leaveType'],
                                          leaveStatus: leaveDoc['leaveStatus'],
                                          leaveDescription:
                                              leaveDoc['leaveDescription'],
                                          fileUrl: leaveDoc['fileUrl'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
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
          )
        ],
      ),
    );
  }
}

class LeaveDetails extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String applicationDate;
  final String leaveType;
  final String leaveStatus;
  final String leaveDescription;
  final String startDate;
  final String endDate;
  final String noOfDays;
  final String fileUrl;

  LeaveDetails({
    required this.firstName,
    required this.lastName,
    required this.applicationDate,
    required this.leaveType,
    required this.leaveStatus,
    required this.leaveDescription,
    required this.startDate,
    required this.endDate,
    required this.noOfDays,
    required this.fileUrl,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DataTable(
                columns: [
                  // Name
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '${widget.firstName} ${widget.lastName}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
                rows: [
                  // Application date
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Applied',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.applicationDate}',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),

                  // start date
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Start Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.startDate}',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),

                  // end date
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'End Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.endDate}',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),

                  // no of days
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Day(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.noOfDays} day(s)',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),

                  // leave type
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Leave Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.leaveType}',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),

                  // leave status
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Leave Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            if (widget.leaveStatus == 'Approved')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  '${widget.leaveStatus}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            if (widget.leaveStatus == 'Rejected')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  '${widget.leaveStatus}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            if (widget.leaveStatus == 'Pending')
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade700,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  '${widget.leaveStatus}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),

              // leave description
              if (widget.leaveType != 'Medical Leave')
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Reason",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              if (widget.leaveType != 'Medical Leave')
                Container(
                  width: 300,
                  margin: EdgeInsets.only(bottom: 16),
                  child: TextField(
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    maxLines: 4,
                    readOnly: true,
                    controller: TextEditingController(
                        text: '${widget.leaveDescription}'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              if (widget.leaveType == 'Medical Leave')
                Image.network(
                  widget.fileUrl,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
