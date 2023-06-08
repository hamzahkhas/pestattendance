// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print, unused_local_variable, unnecessary_import, implementation_imports, avoid_unnecessary_containers

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:pestattendance/model/user.dart';
import 'package:slide_to_act/slide_to_act.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
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
    return Scaffold(
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
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 23),
                child: Text(
                  "Today's Status",
                  style: TextStyle(
                    fontSize: screenWidth / 18,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 32),
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //
                    // checkin section
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Check In",
                            style: TextStyle(
                              fontSize: screenWidth / 22,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            checkIn,
                            style: TextStyle(
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // checkout section
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Check Out",
                            style: TextStyle(
                              fontSize: screenWidth / 22,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            checkOut,
                            style: TextStyle(
                              fontSize: screenWidth / 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(

                      // shows the date
                      text: DateTime.now().day.toString(),
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: screenWidth / 18,
                      ),
                      children: [
                        TextSpan(
                            text:
                                DateFormat(' MMMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: screenWidth / 20,
                            )),
                      ]),
                ),
              ),
              StreamBuilder(

                  // how fast the time updates
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('HH:mm:ss a').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: screenWidth / 20,
                          color: Colors.black38,
                        ),
                      ),
                    );
                  }),
              checkOut == "--/--"
                  ? Container(
                      margin: EdgeInsets.only(top: 24),
                      child: Builder(builder: (context) {
                        final GlobalKey<SlideActionState> key = GlobalKey();

                        return SlideAction(
                          text: checkIn == "--/--"
                              ? "Slide to Check In"
                              : "Slide to Check Out",
                          textStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: screenWidth / 20,
                          ),
                          outerColor: Colors.white,
                          innerColor: Colors.green,
                          key: key,

                          // what happens after sliding slider
                          onSubmit: () async {
                            QuerySnapshot snap = await FirebaseFirestore
                                .instance
                                .collection("User")
                                .where('username', isEqualTo: User.username)
                                .get();

                            DocumentSnapshot snap2 = await FirebaseFirestore
                                .instance
                                .collection("User")
                                .doc(snap.docs[0].id)
                                .collection("Attendance")
                                .doc(DateFormat('dd MMMM yyyy')
                                    .format(DateTime.now()))
                                .get();

                            try {
                              String checkIn = snap2['checkIn'];

                              setState(
                                () {
                                  checkOut = DateFormat('HH:mm')
                                      .format(DateTime.now());
                                },
                              );

                              await FirebaseFirestore.instance
                                  .collection("User")
                                  .doc(snap.docs[0].id)
                                  .collection("Attendance")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .update(
                                {
                                  'date': Timestamp.now(),
                                  'checkIn': checkIn,
                                  'checkOut':
                                      DateFormat('HH:mm').format(DateTime.now())
                                },
                              );
                            } catch (e) {
                              setState(
                                () {
                                  checkIn = DateFormat('HH:mm')
                                      .format(DateTime.now());
                                },
                              );
                              await FirebaseFirestore.instance
                                  .collection("User")
                                  .doc(snap.docs[0].id)
                                  .collection("Attendance")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .set(
                                {
                                  'date': Timestamp.now(),
                                  'checkIn': DateFormat('HH:mm')
                                      .format(DateTime.now()),
                                  'checkOut': "--/--",
                                },
                              );
                            }

                            key.currentState!.reset();
                          },
                        );
                      }),
                    )
                  : Container(
                      margin: const EdgeInsets.only(top: 32),
                      child: Text(
                        "Your day is completed!",
                        style: TextStyle(
                          fontSize: screenWidth / 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
              SizedBox(
                height: 20,
              ),
              Divider(
                color: Colors.black,
                thickness: 1.0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(top: 0),
                child: Text(
                  "Attendance History",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "NexaBold",
                    fontSize: screenWidth / 18,
                  ),
                ),
              ),
              // displaying the month
              Stack(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 23),
                    child: Text(
                      _month,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "NexaBold",
                        fontSize: screenWidth / 18,
                      ),
                    ),
                  ),
                  // choose month to display attendance
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(top: 23),
                    child: GestureDetector(
                      onTap: () async {
                        final month = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2099),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.green.shade700,
                                  secondary: Colors.green.shade700,
                                  onSecondary: Colors.white,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green.shade700,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (month != null) {
                          setState(() {
                            _month = DateFormat('MMMM').format(month);
                          });
                        }
                      },
                      child: Text(
                        "Choose Month",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight / 1.45,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User")
                      .doc(User.docId)
                      .collection("Attendance")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      final snap = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: snap.length,
                        itemBuilder: (context, index) {
                          return DateFormat('MMMM')
                                      .format(snap[index]['date'].toDate()) ==
                                  _month
                              ? Container(
                                  margin: EdgeInsets.only(
                                      top: index > 0 ? 12 : 0,
                                      left: 6,
                                      right: 6),
                                  height: 150,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(),
                                          decoration: BoxDecoration(
                                              color: Colors.green.shade700,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Center(
                                            child: Text(
                                              DateFormat('EE\ndd').format(
                                                  snap[index]['date'].toDate()),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: screenWidth / 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // checkin section
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Check In",
                                              style: TextStyle(
                                                fontSize: screenWidth / 22,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              snap[index]['checkIn'],
                                              style: TextStyle(
                                                fontSize: screenWidth / 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // checkout section
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Check Out",
                                              style: TextStyle(
                                                fontSize: screenWidth / 22,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              snap[index]['checkOut'],
                                              style: TextStyle(
                                                fontSize: screenWidth / 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox();
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
