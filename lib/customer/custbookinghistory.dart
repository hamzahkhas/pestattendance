// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pestattendance/model/user.dart';

class CustBookingHistory extends StatefulWidget {
  const CustBookingHistory({super.key});

  @override
  State<CustBookingHistory> createState() => _CustBookingHistoryState();
}

class _CustBookingHistoryState extends State<CustBookingHistory> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        title: Text(
          'Booking History',
          style: TextStyle(color: Colors.white),
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
                    if (bookingSnapshot['status'] == 'Completed') {
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
                                  completeDate: bookingSnapshot['serviceDate'],
                                  serviceCompleteTime:
                                      bookingSnapshot['serviceCompleteTime'],
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
  final String completeDate;
  final String serviceCompleteTime;

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
    required this.completeDate,
    required this.serviceCompleteTime,
  });

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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
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
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black87,
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
                  maxLines: 3,
                  initialValue: '${widget.bookingDescription}',
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
              SizedBox(
                height: 20,
              ),
              DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      "COMPLETED BY",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "${widget.technicianName}",
                      style: const TextStyle(
                        color: Colors.black87,
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
                          "Tech Contact",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${widget.technicianContact}",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          "Service Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${widget.completeDate}",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          "Complete Time",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${widget.serviceCompleteTime}",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
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
