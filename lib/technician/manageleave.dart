// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, sort_child_properties_last, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/model/user.dart';
import 'package:pestattendance/technician/createleavescreen.dart';

class ManageLeavePage extends StatefulWidget {
  @override
  _ManageLeavePageState createState() => _ManageLeavePageState();
}

class _ManageLeavePageState extends State<ManageLeavePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String selectedStatus = 'All Status';
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
                      newValue ?? 'All Status'; // Update selected role
                });
              },
              items: <String>['All Status', 'Pending', 'Approved', 'Rejected']
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
              stream: db
                  .collection('User')
                  .doc(User.docId)
                  .collection('Leaves')
                  .orderBy('applicationDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> leaveWidgets = [];
                  for (DocumentSnapshot leaveSnapshot in snapshot.data!.docs) {
                    if (selectedStatus == 'All Status' ||
                        leaveSnapshot['leaveStatus'] == selectedStatus) {}
                    leaveWidgets.add(
                      ListTile(
                        title: Row(
                          children: [
                            Text(
                              leaveSnapshot['leaveType'],
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(
                              width: 100,
                            ),
                            Text(leaveSnapshot['leaveStatus']),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Application Date: ',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Text(
                              leaveSnapshot['applicationDate'],
                            ),
                          ],
                        ),
                        // Text(
                        //   'Application Date: ' +
                        //       leaveSnapshot['applicationDate'] +
                        //       ' Status: ' +
                        //       leaveSnapshot['leaveStatus'],
                        // ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaveDetails(
                                applicationDate:
                                    leaveSnapshot['applicationDate'],
                                startDate: leaveSnapshot['startDate'],
                                endDate: leaveSnapshot['endDate'],
                                noOfDays: leaveSnapshot['noOfDays'],
                                leaveType: leaveSnapshot['leaveType'],
                                leaveStatus: leaveSnapshot['leaveStatus'],
                                leaveDescription:
                                    leaveSnapshot['leaveDescription'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return ListView(
                    children: leaveWidgets,
                  );
                } else {
                  return Center(
                    child: Text('No leaves found'),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.green.shade700,
        onPressed: () {
          // Redirect to the CreateUserScreen to create a new user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateLeavePage(),
            ),
          );
        },
      ),
    );
  }
}

class LeaveDetails extends StatefulWidget {
  final String applicationDate;
  final String leaveType;
  final String leaveStatus;
  final String leaveDescription;
  final String startDate;
  final String endDate;
  final String noOfDays;

  LeaveDetails({
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
