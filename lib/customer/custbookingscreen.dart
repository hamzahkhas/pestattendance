// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, sort_child_properties_last, prefer_interpolation_to_compose_strings, must_be_immutable, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/customer/custcreatebooking.dart';
import 'package:pestattendance/model/user.dart';

class CustBooking extends StatefulWidget {
  @override
  _CustBookingState createState() => _CustBookingState();
}

class _CustBookingState extends State<CustBooking> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String selectedStatus = 'Pending';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: Text(
          'Pest Control Booking ',
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
              alignment: Alignment.topCenter,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue ?? 'Pending';
                });
              },
              items: <String>['Pending', 'Confirmed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: db
                  .collection('User')
                  .doc(User.docId)
                  .collection('Booking')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> bookingWidgets = [];
                  for (DocumentSnapshot bookingSnapshot
                      in snapshot.data!.docs) {
                    if (bookingSnapshot['status'] == selectedStatus) {
                      bookingWidgets.add(
                        ListTile(
                          title: Row(
                            children: [
                              Text(
                                bookingSnapshot['preferredDate'].toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Service Time: ',
                                style: TextStyle(color: Colors.black87),
                              ),
                              Text(
                                bookingSnapshot['preferredTime'].toString(),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetails(
                                  applicationDate:
                                      bookingSnapshot['bookingDate'],
                                  pestType: bookingSnapshot['pestType'],
                                  preferredDate:
                                      bookingSnapshot['preferredDate'],
                                  preferredTime:
                                      bookingSnapshot['preferredTime'],
                                  bookingDescription:
                                      bookingSnapshot['bookingDescription'],
                                  status: bookingSnapshot['status'],
                                  technicianName:
                                      bookingSnapshot['technicianName'],
                                  technicianContact:
                                      bookingSnapshot['technicianContact'],
                                  bookingId: bookingSnapshot.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }
                  return ListView(
                    children: bookingWidgets,
                  );
                } else {
                  return Center(
                    child: Text('No bookings found.'),
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
          // Redirect to the create bookingpage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustCreateBooking(),
            ),
          );
        },
      ),
    );
  }
}

class BookingDetails extends StatefulWidget {
  final String applicationDate;
  final String pestType;
  final String preferredDate;
  final String preferredTime;
  String bookingDescription;
  final String status;
  final String technicianName;
  final String technicianContact;
  final String bookingId;

  BookingDetails({
    required this.applicationDate,
    required this.pestType,
    required this.preferredDate,
    required this.preferredTime,
    required this.bookingDescription,
    required this.status,
    required this.technicianName,
    required this.technicianContact,
    required this.bookingId,
  });

  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  late TextEditingController bookingDetailsController;

  @override
  void initState() {
    super.initState();
    bookingDetailsController =
        TextEditingController(text: widget.bookingDescription);
  }

  // delete function: makes sure if its responded, cannot delete the application
  void deleteBooking() {
    if (widget.status == 'Confirmed') {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot Delete: Booking ${widget.status}')));
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
                  deleteBookingFromFirestore();
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

// remove from firestore
  void deleteBookingFromFirestore() async {
    try {
      FirebaseFirestore.instance
          .collection('User')
          .doc(User.docId)
          .collection('Booking')
          .doc(widget.bookingId)
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
          'Booking Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade800,
        leading: IconTheme(
          data: IconThemeData(color: Colors.black),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => deleteBooking(),
            icon: Icon(Icons.delete),
            color: Colors.red,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        "Booking Date",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        '${widget.applicationDate}',
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
                            "Preferred Date",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${widget.preferredDate}',
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
                            "Preferred Time",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${widget.preferredTime}',
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
                            "Booking Status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              if (widget.status == 'Active')
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    '${widget.status}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              if (widget.status == 'Completed')
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    '${widget.status}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              if (widget.status == 'Pending')
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade700,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(6),
                                  child: Text(
                                    '${widget.status}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.status == 'Active')
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              "Tech Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${widget.technicianName}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (widget.status == 'Active')
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              "Tech Contact",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${widget.technicianContact}',
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
                height: 20,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Booking Description",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 300,
                margin: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  maxLines: 6,
                  initialValue: '${widget.bookingDescription}',
                  enabled: false,
                  // controller: bookingDetailsController,
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
              if (widget.status != 'Confirmed')
                ElevatedButton(
                  onPressed: () {
                    String updatedLeaveDescription =
                        bookingDetailsController.text.trim();

                    FirebaseFirestore.instance
                        .collection('User')
                        .doc(User.docId)
                        .collection('Booking')
                        .doc(widget.bookingId)
                        .update({
                      'leaveDescription': updatedLeaveDescription,
                    }).then((value) {
                      setState(() {
                        widget.bookingDescription = updatedLeaveDescription;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Leave Description Updated')),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to update leave description')),
                      );
                    });
                  },
                  child: Text(
                    'Update Details',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
