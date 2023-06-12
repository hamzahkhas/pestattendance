// ignore_for_file: prefer_const_constructors, deprecated_member_use, unused_local_variable, unnecessary_new
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pestattendance/model/user.dart';
import 'package:pestattendance/profilescreen.dart';
import 'package:pestattendance/technician/technicianmanageleave.dart';
import 'package:pestattendance/technician/todayscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  int currentIndex = 1;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.calendarAlt,
    // FontAwesomeIcons.check,
    Icons.holiday_village_outlined,
    FontAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();

    getId();
  }

  void getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("User")
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
          // new CalendarScreen(), // attendance history
          new TodayScreen(), // sign in attendance
          new ManageLeavePage(),
          new ProfileScreen(), // user profile
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
                                ? Colors.green.shade700
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
