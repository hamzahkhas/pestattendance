// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pestattendance/model/user.dart';

class TechBookingHistory extends StatefulWidget {
  const TechBookingHistory({super.key});

  @override
  State<TechBookingHistory> createState() => _TechBookingHistoryState();
}

class _TechBookingHistoryState extends State<TechBookingHistory> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Text(
          'View Booking History',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade800,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('User')
                  .doc(User.docId)
                  .collection('CompletedBooking')
                  .orderBy('bookingDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> completedBooking = [];
                  for (DocumentSnapshot completedSnapshot
                      in snapshot.data!.docs) {
                    if (completedSnapshot['status'] == 'Completed') {
                      completedBooking.add(
                        ListTile(
                          title: Row(
                            children: [
                              Text(
                                completedSnapshot['serviceDate'],
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                width: 170,
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Pest Type: ',
                                style: TextStyle(color: Colors.black87),
                              ),
                              Text(
                                completedSnapshot['pestType'],
                              ),
                              SizedBox(
                                width: 160,
                              ),
                            ],
                          ),

                          // redirect to display leave details
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingDetails(
                                  bookingDate: completedSnapshot['bookingDate'],
                                  custName: completedSnapshot['custName'],
                                  description: completedSnapshot['description'],
                                  pestType: completedSnapshot['pestType'],
                                  serviceCompleteTime:
                                      completedSnapshot['serviceCompleteTime'],
                                  serviceDate: completedSnapshot['serviceDate'],
                                  status: completedSnapshot['status'],
                                  technicianName:
                                      completedSnapshot['technicianName'],
                                  completedId: completedSnapshot.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }
                  return ListView(
                    children: completedBooking,
                  );
                } else {
                  return Center(
                    child: Text('No booking history found'),
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

class BookingDetails extends StatefulWidget {
  final String bookingDate;
  final String custName;
  final String serviceCompleteTime;
  final String description;
  final String serviceDate;
  final String pestType;
  final String status;
  final String technicianName;
  final String completedId;

  BookingDetails(
      {required this.bookingDate,
      required this.custName,
      required this.serviceCompleteTime,
      required this.description,
      required this.serviceDate,
      required this.pestType,
      required this.status,
      required this.technicianName,
      required this.completedId});

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  @override
  void initState() {
    super.initState();
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'Booking Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '${widget.bookingDate}',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Service Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.serviceDate}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Complete Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.serviceCompleteTime}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Pest Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.pestType}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade700,
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
                          ],
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
                  "Description",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                width: 300,
                margin: EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  maxLines: 5,
                  initialValue: widget.description,
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
            ],
          ),
        ),
      ),
    );
  }
}
