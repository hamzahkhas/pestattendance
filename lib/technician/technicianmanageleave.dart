// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, sort_child_properties_last, prefer_interpolation_to_compose_strings, must_be_immutable, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/model/user.dart';
import 'package:pestattendance/technician/techniciancreateleavescreen.dart';

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
                        leaveSnapshot['leaveStatus'] == selectedStatus) {
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
                                  leaveDocumentId: leaveSnapshot.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
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
  String leaveDescription;
  final String startDate;
  final String endDate;
  final String noOfDays;
  final String leaveDocumentId;

  LeaveDetails({
    required this.applicationDate,
    required this.leaveType,
    required this.leaveStatus,
    required this.leaveDescription,
    required this.startDate,
    required this.endDate,
    required this.noOfDays,
    required this.leaveDocumentId,
  });

  @override
  _LeaveDetailsState createState() => _LeaveDetailsState();
}

class _LeaveDetailsState extends State<LeaveDetails> {
  late TextEditingController leaveDescriptionController;

  @override
  void initState() {
    super.initState();
    leaveDescriptionController =
        TextEditingController(text: widget.leaveDescription);
  }

  void deleteLeave() {
    if (widget.leaveStatus == 'Approved' || widget.leaveStatus == 'Rejected') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'This cannot be deleted as it has been ${widget.leaveStatus}')));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete this leave?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  // Delete the leave from Firestore
                  deleteLeaveFromFirestore();
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
  }

  void deleteLeaveFromFirestore() async {
    try {
      FirebaseFirestore.instance
          .collection('User')
          .doc(User.docId)
          .collection('Leaves')
          .doc(widget.leaveDocumentId)
          .delete();
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
          'Leave Details',
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
        actions: [
          IconButton(
            onPressed: () => deleteLeave(),
            icon: Icon(Icons.delete),
            color: Colors.red,
          )
        ],
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
                // enabled: false,
                controller: leaveDescriptionController,
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
            ElevatedButton(
                onPressed: () {
                  String updatedLeaveDescription =
                      leaveDescriptionController.text.trim();

                  FirebaseFirestore.instance
                      .collection('User')
                      .doc(User.docId)
                      .collection('Leaves')
                      .doc(widget.leaveDocumentId)
                      .update({
                    'leaveDescription': updatedLeaveDescription,
                  }).then((value) {
                    setState(() {
                      widget.leaveDescription = updatedLeaveDescription;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Leave Description Updated')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to update leave description')),
                    );
                  });
                },
                child: Text(
                  'Update Details',
                ))
          ],
        ),
      ),
    );
  }
}
