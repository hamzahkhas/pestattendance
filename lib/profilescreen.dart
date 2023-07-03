// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, empty_constructor_bodies

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pestattendance/admin/adminhomescreen.dart';
import 'package:pestattendance/customer/custhomescreen.dart';
import 'package:pestattendance/loginscreen2.dart';
import 'package:pestattendance/manager/managerhomescreen.dart';
import 'package:pestattendance/model/user.dart';
import 'package:pestattendance/technician/technicianhomescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String birth = "Date of Birth";
  String userFirstName = " ";
  String userLastName = '';
  String userPassword = '';
  String userContact = ' ';
  String role = ' ';
  String userAddress = ' ';
  bool updated = false;

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
        role = dataMap!['role'] as String;
        userFirstName = dataMap['firstName'] as String;
        userLastName = dataMap['lastName'] as String;
        userPassword = dataMap['password'] as String;
        userContact = dataMap['contact'] as String;
        userAddress = dataMap['address'] as String;
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
                "$userFirstName",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 120,
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1.0, // Border width
                ),
                color: Colors.white, // Fill color
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the edit screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          firstName: userFirstName,
                          lastName: userLastName,
                          password: userPassword,
                          contact: userContact,
                          address: userAddress,
                          role: role,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Manage Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87, // Text color
                      decoration: TextDecoration.none, // Text decoration
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),

            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 1.0, // Border width
                ),
                color: Colors.white, // Fill color
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () async {
                    signOut();
                    // Navigate to the edit screen
                  },
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade700, // Text color
                      decoration: TextDecoration.none, // Text decoration
                    ),
                  ),
                ),
              ),
            ),

            // textField("First Name", userFirstName),
            // textField("Last Name", userLastName),
            // textField("Contact No.", userContact),
            // textField("Address", userAddress),
            SizedBox(
              height: 150,
            ),
            Text('Profile Screen ' + User.username.toUpperCase()),
            // MaterialButton(
            //   color: Colors.green,
            //   child: Text('Logout'),
            //   onPressed: () async {
            //     signOut();
            //   },
            // ),
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
            title,
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
    await prefs.remove('username');
    await prefs.remove('username');
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen2(),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String password;
  final String contact;
  final String address;
  final String role;

  const EditProfileScreen({
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.contact,
    required this.address,
    required this.role,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController passwordController;
  late TextEditingController contactController;
  late TextEditingController addressController;
  final _confirmPasswordController = TextEditingController();
  bool updated = false;

  double screenWidth = 0;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    passwordController = TextEditingController(text: widget.password);
    contactController = TextEditingController(text: widget.contact);
    addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    contactController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String? _validateContactNo(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Contact No';
    }
    final contactRegExp = RegExp(r'^\d{1,11}$');
    if (!contactRegExp.hasMatch(value)) {
      return 'Contact No must be a numeric value with a maximum of 11 digits';
    }
    return null;
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
            validator: (value) => _validateRequired(value, title),
          ),
        ),
      ],
    );
  }

  Widget textFieldAddress(
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
            maxLines: 3,
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
            validator: (value) => _validateRequired(value, title),
          ),
        ),
      ],
    );
  }

  Widget textFieldContact(
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
            keyboardType: TextInputType.number,
            maxLength: 11, // Maximum length set to 11 digits
            maxLines: 1,
            buildCounter: (BuildContext context,
                    {int? currentLength, int? maxLength, bool? isFocused}) =>
                null, // Remove character counter
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
            validator: _validateContact,
          ),
        ),
      ],
    );
  }

  // validate for each textformfield
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  void updateDetails() async {
    if (_confirmPasswordController.text != passwordController.text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Passwords do not match"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Get the document ID of the user
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('User')
        .where('username', isEqualTo: User.username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      String docId = documentSnapshot.id;

      // Update the user details in Firestore
      await FirebaseFirestore.instance.collection('User').doc(docId).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'password': passwordController.text,
        'contact': contactController.text,
        'address': addressController.text,
      });

      setState(() {
        User.firstName = firstNameController.text;
        User.lastName = lastNameController.text;
        User.password = passwordController.text;
        User.contact = contactController.text;
        User.address = addressController.text;
        User.role = widget.role;
        updated = true;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("User details updated successfully"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  if (widget.role == 'Technician') {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  } else if (widget.role == 'Admin') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminHomeScreen()));
                  } else if (widget.role == 'Manager') {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ManagerHomeScreen()));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustHomeScreen()));
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Information',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: IconTheme(
          data: IconThemeData(color: Colors.black),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  textField("First Name", "Enter your first name",
                      firstNameController),
                  textField(
                      "Last Name", "Enter your last name", lastNameController),

                  // get password
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
                      controller: passwordController,
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
                      validator: (value) =>
                          _validateRequired(value, 'Password'),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Confirm Password",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      cursorColor: Colors.black54,
                      obscureText: true,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
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
                        if (value == null || value.isEmpty) {
                          return 'Please confirm the password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        _validateRequired(value, 'Confirm Password');
                      },
                    ),
                  ),
                  textFieldContact(
                      'Contact no', 'eg: 01134323455', contactController),
                  // get address
                  textFieldAddress("Address", "Your Adress", addressController),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: updateDetails,
                    child: Container(
                      height: 60,
                      width: screenWidth / 1.25,
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25))),
                      child: Center(
                        child: Text(
                          "Update",
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
            ],
          ),
        ),
      ),
    );
  }
}
