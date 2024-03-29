// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_build_context_synchronously, unnecessary_string_interpolations, unnecessary_null_comparison

import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pestattendance/model/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class CreateLeavePage extends StatefulWidget {
  const CreateLeavePage({super.key});

  @override
  State<CreateLeavePage> createState() => _CreateLeavePageState();
}

class _CreateLeavePageState extends State<CreateLeavePage> {
  final _formkey = GlobalKey<FormState>();
  final leaveDescriptionController = TextEditingController();
  bool isButtonClicked = false;

  // default leave type
  String selectedLeaveType = 'Annual Leave';
  String leaveDescription = '';

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int numberOfDays = 0;

// selecting date
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2021),
      lastDate: DateTime(2024),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        numberOfDays = endDate.difference(startDate).inDays + 1;
      });
    }
  }

  // Create leave application
  void createLeave() async {
    if (pickedFile != null) {
      final file = File(pickedFile!.path!);
      final fileName = path.basename(file.path);
      final destination = 'files/$fileName';

      final ref = FirebaseStorage.instance.ref().child(destination);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('User')
          .doc(User.docId)
          .collection('Leaves')
          .add(
        {
          'applicationDate': DateFormat('dd MMMM yyyy').format(DateTime.now()),
          'leaveType': selectedLeaveType,
          'startDate':
              '${startDate != null ? DateFormat('dd MMMM yyyy').format(startDate) : ''}',
          'endDate':
              '${endDate != null ? DateFormat('dd MMMM yyyy').format(endDate) : ''}',
          'noOfDays': '$numberOfDays',
          'leaveDescription': leaveDescriptionController.text,
          'leaveStatus': 'Pending',
          'fileUrl':
              urlDownload, // Add the 'fileUrl' field with the download URL
        },
      );
    } else {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(User.docId)
          .collection('Leaves')
          .add(
        {
          'applicationDate': DateFormat('dd MMMM yyyy').format(DateTime.now()),
          'leaveType': selectedLeaveType,
          'startDate':
              '${startDate != null ? DateFormat('dd MMMM yyyy').format(startDate) : ''}',
          'endDate':
              '${endDate != null ? DateFormat('dd MMMM yyyy').format(endDate) : ''}',
          'noOfDays': '$numberOfDays',
          'leaveDescription': leaveDescriptionController.text,
          'leaveStatus': 'Pending',
          'fileUrl': '',
        },
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success!'),
          content: Text('Leave applied successfully!'),
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

  PlatformFile? pickedFile;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  UploadTask? uploadTask;

  Future uploadFile() async {
    if (pickedFile == null) {
      return; // No file selected
    }

    final file = File(pickedFile!.path!);
    final fileName = pickedFile!.name;
    final destination = 'files/$fileName';

    final ref =
        firebase_storage.FirebaseStorage.instance.ref().child(destination);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Leave',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade800,
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
                // leavetype
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
                      width: 30,
                    ),
                    DropdownButton<String>(
                      value: selectedLeaveType,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedLeaveType = newValue;
                          });
                        }
                      },
                      items: [
                        'Annual Leave',
                        'Unpaid Leave',
                        'Medical Leave',
                        'Emergency Leave'
                      ].map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),

                // select leave date
                Row(
                  children: [
                    Text(
                      'Leave Date(s)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDateRange(context),
                      child: Text('Select Date Range'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.green.shade700.withOpacity(0.5);
                            } else if (states
                                .contains(MaterialState.disabled)) {
                              return Colors.green.shade700.withOpacity(0.5);
                            }
                            return Colors.green.shade700;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // display start date
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Start Date",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 33,
                    ),
                    Text(
                      ' ${startDate != null ? DateFormat('dd MMMM yyyy').format(startDate) : ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // display end date
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "End Date",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 41,
                    ),
                    Text(
                      ' ${endDate != null ? DateFormat('dd MMMM yyyy').format(endDate) : ''}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),

                // display no of days
                Row(
                  children: [
                    Text(
                      "No of Day(s)",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      '$numberOfDays',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                if (selectedLeaveType != 'Medical Leave')
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
                if (selectedLeaveType != 'Medical Leave')
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      style: TextStyle(fontSize: 16),
                      controller: leaveDescriptionController,
                      cursorColor: Colors.black54,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: "Enter your leave reason",
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
                          return "Please enter your leave reason";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),

                if (selectedLeaveType == 'Medical Leave')
                  Column(
                    children: [
                      ElevatedButton(
                          onPressed: selectFile, child: Text('Select File')),
                      _buildSelectedFileWidget(),
                      if (pickedFile != null)
                        GestureDetector(
                          onTap: createLeave,
                          child: Container(
                            height: 50,
                            width: 200,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(25))),
                            child: Center(
                              child: Text(
                                "Apply",
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
                SizedBox(
                  height: 20,
                ),
                if (selectedLeaveType != 'Medical Leave')
                  GestureDetector(
                    onTap: () {
                      if (!isButtonClicked) {
                        isButtonClicked = true;
                        createLeave();
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
                          "Apply",
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

  Widget _buildSelectedFileWidget() {
    if (pickedFile != null) {
      if (pickedFile!.extension == 'jpg' ||
          pickedFile!.extension == 'jpeg' ||
          pickedFile!.extension == 'png') {
        return Image.file(
          File(pickedFile!.path!),
          width: 400,
          height: 600,
          fit: BoxFit.cover,
        );
      } else {
        return Text(
          pickedFile!.name,
          style: TextStyle(fontSize: 16),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
