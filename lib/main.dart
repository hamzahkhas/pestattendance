// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:pestattendance/admin/adminhomescreen.dart';
import 'package:pestattendance/customer/custhomescreen.dart';
import 'package:pestattendance/loginscreen2.dart';
import 'package:pestattendance/model/user.dart';
import 'package:pestattendance/profilescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'technician/homescreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: KeyboardVisibilityProvider(child: AuthCheck()),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // get the current username
  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();

    try {
      // save username to the class from main.dart
      if (sharedPreferences.getString('username') != null) {
        setState(() {
          User.username = sharedPreferences.getString('username')!;
          userAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        userAvailable = false;
      });
    }
  }

  Future<Map<String, dynamic>> getData() async {
    if (sharedPreferences.getString('username') != null &&
        sharedPreferences.getString('username') != "") {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username',
              isEqualTo: sharedPreferences.getString('username')!)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        return documentSnapshot.data() as Map<String, dynamic>;
      }
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    // return userAvailable ? HomeScreen() : const LoginScreen2();

    return userAvailable
        ? FutureBuilder<Map<String, dynamic>>(
            future: getData(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                Map<String, dynamic> dataMap = snapshot.data!;
                // Render the data as needed

                // Build your UI using the data
                if (dataMap['role'] == "Admin") {
                  return AdminHomeScreen();
                } else if (dataMap['role'] == "Technician") {
                  return HomeScreen();
                } else if (dataMap['role'] == "cust") {
                  return CustHomeScreen();
                } else {
                  return ProfileScreen();
                }
              } else {
                return Center(
                  child: Text('No data available'),
                );
              }
            },
          )
        : const LoginScreen2();
  }
}
