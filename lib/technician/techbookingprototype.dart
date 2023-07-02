// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, must_be_immutable, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pestattendance/model/user.dart';
import 'package:url_launcher/url_launcher.dart';

class TechBooking extends StatefulWidget {
  const TechBooking({super.key});

  @override
  State<TechBooking> createState() => _TechBookingState();
}

class _TechBookingState extends State<TechBooking> {
  double screenHeight = 0;
  double screenWidth = 0;
  String firstName = '';
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String selectedStatus = 'Pending';

  void _getFirstName() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('username', isEqualTo: User.username)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic>? dataMap =
          documentSnapshot.data() as Map<String, dynamic>?;
      setState(() {
        firstName = dataMap!['firstName'] as String;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getFirstName();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade800,
        title: Text(
          'Welcome $firstName!',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
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
              items: <String>['Pending', 'Confirmed']
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
                    child: Text('Error fetching data.'),
                  );
                } else if (userSnapshot.hasData) {
                  List<Widget> bookingWidget = [];

                  return FutureBuilder<void>(
                    future: Future.forEach(userSnapshot.data!.docs,
                        (userDoc) async {
                      String docId = userDoc.id;

                      // retrieve the booking details
                      QuerySnapshot bookingSnapshot = await db
                          .collection('User')
                          .doc(docId)
                          .collection('Booking')
                          .get();

                      if (bookingSnapshot.docs.isNotEmpty) {
                        // Process the bookingsnapshot data
                        for (DocumentSnapshot bookingDoc
                            in bookingSnapshot.docs) {
                          // pending
                          if (bookingDoc['status'] == selectedStatus) {
                            if (selectedStatus == 'Pending' &&
                                bookingDoc['username'] == null) {
                              bookingWidget.add(
                                ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        bookingDoc['pestType'],
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
                                        bookingDoc['bookingDate'],
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
                                        builder: (context) => BookingDetails(
                                          applicationDate:
                                              bookingDoc['bookingDate'],
                                          pestType: bookingDoc['pestType'],
                                          preferredDate:
                                              bookingDoc['preferredDate'],
                                          preferredTime:
                                              bookingDoc['preferredTime'],
                                          bookingDescription:
                                              bookingDoc['bookingDescription'],
                                          status: bookingDoc['status'],
                                          technicianName:
                                              bookingDoc['technicianName'],
                                          technicianContact:
                                              bookingDoc['technicianContact'],
                                          custAddress:
                                              bookingDoc['custAddress'],
                                          custContact:
                                              bookingDoc['custContact'],
                                          bookingId: bookingDoc.id,
                                          userId: docId,
                                          firstName: userDoc['firstName'],
                                          lastName: userDoc['lastName'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (selectedStatus == 'Confirmed' &&
                                bookingDoc['username'] == User.username) {
                              bookingWidget.add(
                                ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        bookingDoc['pestType'],
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
                                        bookingDoc['bookingDate'],
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
                                        builder: (context) => BookingDetails(
                                          applicationDate:
                                              bookingDoc['bookingDate'],
                                          pestType: bookingDoc['pestType'],
                                          preferredDate:
                                              bookingDoc['preferredDate'],
                                          preferredTime:
                                              bookingDoc['preferredTime'],
                                          bookingDescription:
                                              bookingDoc['bookingDescription'],
                                          status: bookingDoc['status'],
                                          technicianName:
                                              bookingDoc['technicianName'],
                                          technicianContact:
                                              bookingDoc['technicianContact'],
                                          custAddress:
                                              bookingDoc['custAddress'],
                                          custContact:
                                              bookingDoc['custContact'],
                                          bookingId: bookingDoc.id,
                                          userId: docId,
                                          firstName: userDoc['firstName'],
                                          lastName: userDoc['lastName'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          }
                        }
                      }
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        if (bookingWidget.isNotEmpty) {
                          return ListView(
                            children: bookingWidget,
                          );
                        } else {
                          return Center(
                            child: Text('No booking found.'),
                          );
                        }
                      }
                    },
                  );
                } else {
                  return Center(
                    child: Text('No users found.'),
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

class BookingDetails extends StatefulWidget {
  final String applicationDate;
  final String pestType;
  final String preferredDate;
  final String preferredTime;
  String bookingDescription;
  String status;
  final String technicianName;
  final String technicianContact;
  final String custContact;
  final String custAddress;
  final String bookingId;
  final String userId;
  final String firstName;
  final String lastName;

  BookingDetails({
    required this.applicationDate,
    required this.pestType,
    required this.preferredDate,
    required this.preferredTime,
    required this.bookingDescription,
    required this.status,
    required this.custAddress,
    required this.custContact,
    required this.technicianName,
    required this.technicianContact,
    required this.bookingId,
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  late bool isButtonClicked = false;

  void getUserData() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('username', isEqualTo: User.username)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data() as Map<String, dynamic>;
      setState(
        () {
          User.address = userData['address'];
          User.contact = userData['contact'];
          User.firstName = userData['firstName'];
          User.lastName = userData['lastName'];
          // Update other User properties if needed
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    isButtonClicked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pest: ${widget.pestType}',
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
                    '${widget.firstName} ',
                    style: TextStyle(fontSize: 16),
                  )),
                ],
                rows: [
                  // DataRow(
                  //   cells: [
                  //     DataCell(
                  //       Text(
                  //         'Date',
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //     ),
                  //     DataCell(
                  //       Text(
                  //         '${widget.applicationDate}',
                  //         style: TextStyle(fontSize: 16),
                  //       ),
                  //     )
                  //   ],
                  // ),
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
                          '${widget.preferredDate}',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Service Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${widget.preferredTime}',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
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
                            if (widget.status == 'Confirmed')
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
                      )
                    ],
                  ),
                  if (widget.status == 'Confirmed')
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            'Contact No',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              launch("tel:${widget.custContact}");
                            },
                            child: Text(
                              '${widget.custContact}',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),

              // address
              if (widget.status != 'Completed')
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Address",
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
              if (widget.status != 'Completed')
                Container(
                  width: 300,
                  margin: EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    maxLines: 2,
                    initialValue: '${widget.custAddress}',
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
              SizedBox(
                height: 10,
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
                height: 10,
              ),

              if (widget.status == 'Confirmed')
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Text(
                        "Technician Name",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${widget.technicianName}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              if (widget.status == 'Pending')
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!isButtonClicked) {
                            isButtonClicked = true;
                          }
                          updateBookingStatus('Confirmed');
                        },
                        child: Container(
                          height: 50,
                          width: 200,
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Accept',
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
                ),

              if (widget.status == 'Confirmed')
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!isButtonClicked) {
                            isButtonClicked = true;
                          }
                          updateBookingStatus('Completed');
                        },
                        child: Container(
                          height: 50,
                          width: 200,
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Completed',
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  void updateBookingStatus(String newStatus) {
    if (newStatus == 'Completed') {
      FirebaseFirestore.instance
          .collection('User')
          .doc(User.docId)
          .collection('CompletedBooking')
          .add(
        {
          'serviceDate': DateFormat('dd MMMM yyyy').format(DateTime.now()),
          'serviceCompleteTime':
              DateFormat('HH:mm:ss a').format((DateTime.now())),
          'custName': widget.firstName,
          'pestType': widget.pestType,
          'status': newStatus,
          'description': widget.bookingDescription,
          'technicianName': widget.firstName,
          'bookingDate': widget.applicationDate,
        },
      );
    }
    FirebaseFirestore.instance
        .collection('User')
        .doc(widget.userId)
        .collection('Booking')
        .doc(widget.bookingId)
        .update({
      'status': newStatus,
      'technicianName': User.firstName,
      'technicianContact': User.contact,
    }).then((value) {
      setState(() {
        widget.status = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking is ' + newStatus + '!'),
        ),
      );
    }).catchError((error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ' + newStatus + ' booking!')),
      );
    });
  }
}
