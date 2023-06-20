// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, avoid_print, use_build_context_synchronously, unused_local_variable
// ignore_for_file: prefer_const_literals_to_create_immutables

/* 
  IMPORTANT: 
  snap is for the user credentials
  snap2 is for attendance information
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pestattendance/admin/adminhomescreen.dart';
import 'package:pestattendance/customer/custhomescreen.dart';
import 'package:pestattendance/manager/managerhomescreen.dart';
import 'package:pestattendance/technician/technicianhomescreen.dart';
import 'package:pestattendance/signupscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen2 extends StatefulWidget {
  const LoginScreen2({Key? key}) : super(key: key);

  @override
  State<LoginScreen2> createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences sharedPreferences;
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color.fromARGB(0, 255, 255, 255);

  @override
  Widget build(BuildContext context) {
    // final bool isKeyboardVisible =
    //     KeyboardVisibilityProvider.isKeyboardVisible(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // company logo
          Image.asset(
            'assets/easelife.png',
            height: 200,
            width: 200,
          ),

          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: Text(
              "WELCOME",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),

          // welcome text
          // isKeyboardVisible
          //     ? SizedBox()
          //     : Container(
          //         margin: EdgeInsets.only(
          //             top: screenHeight / 100, bottom: screenHeight / 10),
          //         child: Text(
          //           "Welcome",
          //           style: TextStyle(fontSize: screenWidth / 12),
          //         ),
          //       ),

          // username and password text field
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: screenWidth / 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldTitle("Username"),
                customTextField("Enter Username", usernameController,
                    false), // username textfield
                fieldTitle("Password"),
                customTextField("Enter Password", passwordController,
                    true), // password textfield
                // login button
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    String username = usernameController.text.trim();
                    String password = passwordController.text.trim();

                    // check if username/password is empty
                    if (username.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Username field is empty!"),
                      ));
                    } else if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Password field is empty!"),
                      ));
                    } else {
                      // verify username and password
                      QuerySnapshot snap = await FirebaseFirestore.instance
                          .collection("User")
                          .where('username', isEqualTo: username)
                          .limit(1)
                          .get();

                      try {
                        // check if password is correct
                        if (snap.size == 1 &&
                            snap.docs.first.get('password') == password) {
                          final sharedPreferences =
                              await SharedPreferences.getInstance();
                          await sharedPreferences.setString(
                              'username', username);
                          //
                          // get role of users
                          String role = snap.docs.first.get('role');

                          // redirect accordingly
                          switch (role) {
                            case 'Admin':
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminHomeScreen()),
                              );
                              break;
                            case 'Technician':
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                              );
                              break;
                            case 'Customer':
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CustHomeScreen()),
                              );
                              break;
                            case 'Manager':
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ManagerHomeScreen()),
                              );
                              break;
                            default:
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen2()),
                              );
                          }
                        } else {
                          // return error message
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Username or password is incorrect!"),
                          ));
                        }
                      } catch (e) {
                        String error = " ";

                        if (e.toString() ==
                            "RangeError (index): Invalid value: Valid value range is empty: 0") {
                          error = 'Username does not exist';
                        } else {
                          error = "Error has occured!";
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(error),
                        ));

                        setState(() {});
                      }
                    }
                  },

                  // login button
                  child: Container(
                    height: 60,
                    width: screenWidth,
                    margin: EdgeInsets.only(top: screenHeight / 40),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25))),
                    child: Center(
                      child: Text(
                        "Log In",
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "New here? Sign Up",
                        style: TextStyle(
                            fontSize: 16, color: Colors.green.shade700),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
        ),
      ),
    );
  }

  Widget customTextField(
      String hint, TextEditingController controller, bool obscure) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: screenHeight / 30),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ]),

      // textfield row
      child: Row(
        children: [
          Container(
            width: screenWidth / 6,
            child: Icon(
              Icons.person,
              color: Colors.green.shade700,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight / 35,
                    ),
                    border: InputBorder.none,
                    hintText: hint),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          )
        ],
      ),
    );
  }
}
