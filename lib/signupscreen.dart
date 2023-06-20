// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pestattendance/loginscreen2.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  double screenHeight = 0;
  double screenWidth = 0;

  void _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;

      // check for username if duplicate
      final QuerySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      // if already exists
      if (QuerySnapshot.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Username is taken!"),
              content: Text("Choose a different username."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // save to firebase
        await FirebaseFirestore.instance.collection('User').add(
          {
            'username': username,
            'password': _passwordController.text,
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'contact': _contactController.text,
            'role': "Customer",
            // 'email': _emailController.text,
            'address': _addressController.text,
          },
        );

        // show success message and navigate to login
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success!'),
              content: Text('User signed up successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen2(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
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
                "User Registration",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "NexaBold",
                  fontSize: screenWidth / 18,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    textField(
                        "Username", "Unique Username", _usernameController),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Password",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: _passwordController,
                        cursorColor: Colors.black54,
                        obscureText: true,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Password",
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
                            return "Please enter password";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    textField(
                        "First Name", "Your First Name", _firstNameController),
                    textField(
                        "Last Name", "Your Last Name", _lastNameController),
                    textField(
                        "Contact No", "Your Phone Number", _contactController),
                    textField("Address", "Your Adress", _addressController),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _signUpUser,
              child: Container(
                height: 60,
                width: screenWidth / 1.25,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: const BorderRadius.all(Radius.circular(25))),
                child: Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen2()));
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    "Have an account already? Log In",
                    style:
                        TextStyle(fontSize: 16, color: Colors.green.shade700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textField(
      String title, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
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
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter your " + title;
              } else {
                return null;
              }
            },
          ),
        ),
      ],
    );
  }
}
