// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, must_be_immutable, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagerLeaveScreen extends StatefulWidget {
  const ManagerLeaveScreen({super.key});

  @override
  State<ManagerLeaveScreen> createState() => _ManagerLeaveScreenState();
}

class _ManagerLeaveScreenState extends State<ManagerLeaveScreen> {
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
            width: 200,
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedStatus,
              alignment: Alignment.center,
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
                                        leaveDoc['leaveType'],
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        'Applied: ',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      Text(
                                        leaveDoc['applicationDate'],
                                      ),
                                      SizedBox(
                                        width: 140,
                                      ),
                                      Text(userDoc['firstName'])
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
                                          leaveDocumentId: leaveDoc.id,
                                          fileUrl: leaveDoc['fileUrl'],
                                          userId: docId,
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
          ),
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
  String leaveStatus;
  final String leaveDescription;
  final String startDate;
  final String endDate;
  final String noOfDays;
  final String leaveDocumentId;
  final String userId;
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
    required this.leaveDocumentId,
    required this.userId,
    required this.fileUrl,
  });

  @override
  _LeaveDetailsState createState() => _LeaveDetailsState();
}

class _LeaveDetailsState extends State<LeaveDetails> {
  late bool isButtonClicked = false;

  @override
  void initState() {
    super.initState();
    isButtonClicked = false;
  }

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
              IconThemeData(color: Colors.white), // Set the desired color here
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
                      ),
                    ],
                  ),
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
                      ),
                    ],
                  ),
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
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Days',
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
                      ),
                    ],
                  ),
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
                      ),
                    ],
                  ),
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
                        Text(
                          '${widget.leaveStatus}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
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
                  child: TextFormField(
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    maxLines: 4,
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
              if (widget.leaveStatus == 'Pending')
                Row(
                  children: [
                    SizedBox(
                      width: 45,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!isButtonClicked) {
                          isButtonClicked = true;
                        }
                        updateLeaveStatus('Rejected');
                      },
                      child: Container(
                        height: 50,
                        width: 125,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Reject',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                letterSpacing: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!isButtonClicked) {
                          isButtonClicked = true;
                        }
                        updateLeaveStatus('Approved');
                      },
                      child: Container(
                        height: 50,
                        width: 125,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Approve',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                letterSpacing: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 20,
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

  void updateLeaveStatus(String newStatus) {
    FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userId)
        .collection('Leaves')
        .doc(widget.leaveDocumentId)
        .update({
      'leaveStatus': newStatus,
    }).then((value) {
      setState(() {
        widget.leaveStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave is ' + newStatus + '!'),
        ),
      );
    }).catchError((error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ' + newStatus + ' leave status')),
      );
    });
  }
}
