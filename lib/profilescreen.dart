// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pestattendance/loginscreen2.dart';
import 'package:pestattendance/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String birth = "Date of Birth";
  String firstName = " ";

  @override
  void initState() {
    super.initState();
    _getFirstName();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 80, bottom: 24),
              height: 120,
              width: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green.shade700,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Technician $firstName",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            textField("First Name", "First name"),
            textField("Last Name", "Last name"),
            textField("Contact No.", "Phone No."),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                birth,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            Container(
              height: kToolbarHeight,
              width: screenWidth,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.black54,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 11),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Date of Birth",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            textField("Address", "Adress"),
            Text('Profile Screen ' + User.username.toUpperCase()),
            MaterialButton(
              color: Colors.green,
              child: Text('Logout'),
              onPressed: () async {
                signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget textField(String title, String hint) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Date of Birth",
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          child: TextFormField(
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
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
          ),
        ),
      ],
    );
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen2(),
      ),
    );
  }
}
