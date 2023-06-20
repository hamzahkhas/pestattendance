// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, sort_child_properties_last, prefer_interpolation_to_compose_strings, must_be_immutable, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/customer/custcreatebookingscreen.dart';
import 'package:pestattendance/model/user.dart';

class CustBooking extends StatefulWidget {
  @override
  _CustBookingState createState() => _CustBookingState();
}

class _CustBookingState extends State<CustBooking> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Service Booking',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
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
                    bookingWidgets.add(
                      ListTile(
                        title: Row(
                          children: [
                            Text(
                              bookingSnapshot['bookingDate'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Service Time',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Text(
                              bookingSnapshot['serviceTime'],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetails(
                                bookingDate: bookingSnapshot['bookingDate'],
                                serviceTime: bookingSnapshot['serviceTime'],
                                bookingDetails:
                                    bookingSnapshot['bookingDetails'],
                                bookingStatus: bookingSnapshot['bookingStatus'],
                                bookingId: bookingSnapshot.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
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
          // Redirect to the CreateUserScreen to create a new user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewBookingPage(),
            ),
          );
        },
      ),
    );
  }
}

class BookingDetails extends StatefulWidget {
  final String bookingDate;
  final String serviceTime;
  String bookingDetails;
  final String bookingStatus;
  final String bookingId;

  BookingDetails({
    required this.bookingDate,
    required this.serviceTime,
    required this.bookingDetails,
    required this.bookingStatus,
    required this.bookingId,
  });

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  late TextEditingController bookingDetailsController;

  @override
  void initState() {
    super.initState();
    // bookingDetailsController = TextEditingController(text: widget.bookingDetails);
  }

  // delete function: makes sure if its responded, cannot delete the application
  void deleteBooking() {
    if (widget.bookingStatus == 'Confirmed') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cannot Delete: Booking ${widget.bookingStatus}')));
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
                        '${widget.bookingDate}',
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
                            "Service Time",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${widget.serviceTime}',
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
                          Text(
                            '${widget.bookingStatus}',
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
                  initialValue: '${widget.bookingDetails}',
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
              if (widget.bookingStatus != 'Confirmed')
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
                        widget.bookingDetails = updatedLeaveDescription;
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
