// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_build_context_synchronously, unnecessary_string_interpolations, unnecessary_null_comparison

import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pestattendance/customer/custbookingscreen.dart';
import 'package:pestattendance/model/user.dart';

class CreateNewBookingPage extends StatefulWidget {
  const CreateNewBookingPage({super.key});

  @override
  State<CreateNewBookingPage> createState() => _CreateNewBookingPageState();
}

class _CreateNewBookingPageState extends State<CreateNewBookingPage> {
  final _formkey = GlobalKey<FormState>();
  final bookingController = TextEditingController();
  bool isButtonClicked = false;

  TimeOfDay _selectedTime = TimeOfDay(hour: 9, minute: 0);

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

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int numberOfDays = 0;

// select date of booking
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void createBooking() async {
    final db2 = FirebaseFirestore.instance.collection('User').doc(User.docId);

    final bookingCollection = db2.collection('Booking');

    // check if collection exists
    final bookingCollectionSnapshot = await bookingCollection.get();
    if (bookingCollectionSnapshot.docs.isEmpty) {
      // 'Booking' collection does not exist, create it
      await bookingCollection.add({});
    }
    await bookingCollection.add(
      {
        'applicationDate': DateFormat('dd MMMM yyyy').format(DateTime.now()),
        'preferredDate': selectedDate,
        'preferredTime': _selectedTime,
        'bookingDetails': bookingController.text,
        'status': 'Pending',
        'technicianName': '-',
        'technicianContact': '-',
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

  DateTime? selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Booking',
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
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          'Preferred Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Row(
                          children: [
                            if (selectedDate == null)
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    'Select Date',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            if (selectedDate != null)
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(selectedDate!),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'Preferred Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataCell(
                            DropdownButtonFormField(
                              value: _selectedTime,
                              onChanged: (value) {
                                setState(
                                  () {
                                    _selectedTime = value!;
                                  },
                                );
                              },
                              items: _buildTimeOptions(),
                              decoration: InputDecoration(
                                hintText: 'Select Time',
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                border: OutlineInputBorder(),
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
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    style: TextStyle(fontSize: 16),
                    controller: bookingController,
                    cursorColor: Colors.black54,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Write your pest problems.",
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
                        return "Please enter your pest problem!";
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
