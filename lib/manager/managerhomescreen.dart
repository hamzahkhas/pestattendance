// ignore_for_file: prefer_const_constructors, deprecated_member_use
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pestattendance/manager/managerattdscreen2.dart';
import 'package:pestattendance/manager/managerbooking.dart';
import 'package:pestattendance/manager/managerleavescreen.dart';
import 'package:pestattendance/model/user.dart';
import 'package:pestattendance/profilescreen.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String id = '';

  int currentIndex = 1;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.servicestack,
    FontAwesomeIcons.calendarAlt,
    FontAwesomeIcons.list,
    // FontAwesomeIcons.userPlus,
    FontAwesomeIcons.userAlt,
  ];

  @override
  void initState() {
    super.initState();

    getId();
  }

  void getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .where('username', isEqualTo: User.username)
        .get();

    setState(() {
      User.docId = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // redirect to respective screen
      body: IndexedStack(
        index: currentIndex,
        children: [
          ManagerBooking(),
          ManagerLeaveScreen(),
          ManagerAttd(),
          // ManageUserScreen(),
          ProfileScreen(), // user profile
        ],
      ),

      // bottom navigation bar
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ]),
        child: ClipRRect(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            navigationIcons[i],
                            color: i == currentIndex
                                ? Colors.blue.shade800
                                : Colors.black26,
                            size: i == currentIndex ? 28 : 24,
                          ),
                          i == currentIndex
                              ? Container(
                                  margin: EdgeInsets.only(top: 6),
                                  height: 3,
                                  width: 18,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
