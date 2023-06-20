import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pestattendance/model/user.dart';

class ManageCustBooking extends StatefulWidget {
  const ManageCustBooking({super.key});

  @override
  State<ManageCustBooking> createState() => _ManageCustBookingState();
}

class _ManageCustBookingState extends State<ManageCustBooking> {
  double screenHeight = 0;
  double screenWidth = 0;
  String firstName = '';

  // get firstname
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
    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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
    ));
  }
}
