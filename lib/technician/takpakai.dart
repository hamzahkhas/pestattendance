// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:pestattendance/model/user.dart';
import 'package:slide_to_act/slide_to_act.dart';

class ManageCustBooking extends StatefulWidget {
  const ManageCustBooking({super.key});
  @override
  State<ManageCustBooking> createState() => _ManageCustBookingState();
}

class _ManageCustBookingState extends State<ManageCustBooking> {
  double screenHeight = 0;
  double screenWidth = 0;
  String checkIn = "--/--";
  String checkOut = "--/--";
  String firstName = " ";

  String _month = DateFormat('MMM').format(DateTime.now());

  Future<void> _refresh() async {
    // Implement your refresh logic here.
    // For example, you could fetch new data from a remote API.
    await Future.delayed(Duration(seconds: 2));
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("User")
        .where('username', isEqualTo: User.username)
        .get();
    DocumentSnapshot snap2 = await FirebaseFirestore.instance
        .collection("User")
        .doc(snap.docs[0].id)
        .collection("Attendance")
        .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
        .get();
    setState(() {
      checkIn = snap2['checkIn'];
      checkOut = snap2['checkOut'];
    });
  }

  @override
  void initState() {
    super.initState();
    _getAttendance();
    _getFirstName();
  }

  void _getAttendance() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("User")
          .where('username', isEqualTo: User.username)
          .get();
      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("User")
          .doc(snap.docs[0].id)
          .collection("Attendance")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();
      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

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
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // welcome text
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 23),
                  child: Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: screenWidth / 20,
                    ),
                  ),
                ),
                // technician name
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Technician $firstName",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth / 18,
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
