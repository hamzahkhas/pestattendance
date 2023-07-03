// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_build_context_synchronously, unnecessary_string_interpolations, unnecessary_null_comparison

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pestattendance/model/user.dart';

class CustCreateBooking extends StatefulWidget {
  const CustCreateBooking({super.key});

  @override
  State<CustCreateBooking> createState() => _CustCreateBookingState();
}

class _CustCreateBookingState extends State<CustCreateBooking> {
  final _formkey = GlobalKey<FormState>();
  final bookingDetailsController = TextEditingController();
  bool isButtonClicked = false;

  // default leave type
  String selectedPest = 'Ants';
  String bookingDetails = '';

  DateTime? selectedDate = DateTime.now();
  int numberOfDays = 0;
  TimeOfDay selectedTime = TimeOfDay(hour: 9, minute: 0);

// select date function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2029),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // select time function
  List<DropdownMenuItem<TimeOfDay>> _buildTimeOptions() {
    List<DropdownMenuItem<TimeOfDay>> items = [];
    for (int hour = 9; hour <= 16; hour++) {
      items.add(
        DropdownMenuItem(
          value: TimeOfDay(hour: hour, minute: 0),
          child: Text('${hour.toString().padLeft(2, '0')}:00'),
        ),
      );
    }
    return items;
  }

  // create booking appointment
  void createBooking() async {
    final formattedTime = selectedTime.format(context);

    await FirebaseFirestore.instance
        .collection('User')
        .doc(User.docId)
        .collection('Booking')
        .add(
      {
        'bookingDate': DateFormat('dd MMMM yyyy').format(DateTime.now()),
        'pestType': selectedPest,
        'preferredDate': DateFormat('dd MMMM yyyy').format(selectedDate!),
        'preferredTime': formattedTime,
        'bookingDescription': bookingDetailsController.text,
        'custAddress': User.address,
        'custContact': User.contact,
        'status': 'Pending',
        'technicianName': '',
        'technicianContact': '',
        'serviceDate': '',
        'serviceCompleteTime': '',
      },
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success!'),
          content: Text('Booking made successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

// get user data
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Booking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
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
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        'Pest Type ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: DropdownButton<String>(
                        value: selectedPest,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedPest = newValue;
                            });
                          }
                        },
                        items: <String>[
                          'Ants',
                          'Cockroaches',
                          'Bed bugs',
                          'Termites'
                        ].map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            'Preferred Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (selectedDate != null)
                          DataCell(
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('dd MMMM yyyy')
                                      .format(selectedDate!),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            "Preferred Time",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          DropdownButtonFormField(
                            value: selectedTime,
                            items: _buildTimeOptions(),
                            onChanged: (value) {
                              setState(() {
                                selectedTime = value!;
                              });
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    "Pest Description",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    style: TextStyle(fontSize: 16),
                    controller: bookingDetailsController,
                    cursorColor: Colors.black54,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Write problems regarding pests.",
                      hintStyle: TextStyle(
                        color: Colors.black54,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black54,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your pest problems.";
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (!isButtonClicked) {
                      isButtonClicked = true;
                      createBooking();
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25))),
                    child: Center(
                      child: Text(
                        "Book",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
