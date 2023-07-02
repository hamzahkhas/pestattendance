// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:pestattendance/admin/adminmanageusersscreen.dart';

class CreateUserScreen extends StatefulWidget {
  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  String selectedRole = 'Technician';

  void createUser() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

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
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Passwords do not match!"),
            content: Text("Input correct passwords."),
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
          'role': selectedRole,
          'address': _addressController.text,
          'nfcIdentifier': _tagValueController.text,
        },
      );

      // show success message and navigate to managescreen
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Success!'),
            content: Text('User created successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageUserScreen(),
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

  // validate for each textformfield
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  final TextEditingController _tagValueController = TextEditingController();

  List<int> tagValue = [];

  void initNfc() async {
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        readNfcTag(tag);
      },
    );
  }

  Future<List<int>> getTagValue(NfcTag tag) async {
    // Retrieve and process the tag value here
    // Replace this with your actual logic to get the tag value
    Ndef? ndef = Ndef.from(tag);
    if (ndef == null) {
      throw Exception("Tag isn't NDEF formatted.");
    }
    print(ndef.additionalData['identifier']);

    List<int> tagValue = ndef.additionalData['identifier'];
    return tagValue;
  }

  void readNfcTag(NfcTag tag) async {
    try {
      List<int> tagValue = await getTagValue(tag);

      setState(() {
        this.tagValue = tagValue;
        _tagValueController.text = tagValue.join('');
      });
    } catch (e) {
      // Handle any errors that occur during reading
    }
  }

  @override
  void initState() {
    super.initState();
    initNfc();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade800,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Create User'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // get username
                  textField("Username", "Unique Username", _usernameController),

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
                      validator: (value) =>
                          _validateRequired(value, 'Password'),
                    ),
                  ),

                  // get confirm password
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
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        _validateRequired(value, 'Confirm Password');
                      },
                    ),
                  ),

                  // get first name
                  textField("First Name", "Enter your first name",
                      _firstNameController),

                  //  get last name
                  textField(
                      "Last Name", "Enter your last name", _lastNameController),

                  // get user role
                  Row(
                    children: [
                      Text(
                        'User Role',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      DropdownButton<String>(
                        value: selectedRole,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedRole = newValue;
                            });
                          }
                        },
                        items: <String>['Technician', 'Manager']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // get contact no
                  textField(
                      "Contact No", "Your Phone Number", _contactController),

                  // get address
                  textField("Address", "Your Adress", _addressController),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'NFC Tag Value:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _tagValueController.text != ""
                        ? _tagValueController.text
                        : "Not scanned yet",
                    style: TextStyle(fontSize: 16),
                  ),

                  GestureDetector(
                    onTap: createUser,
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
                          "Create User",
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
            ),
          ),
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
            validator: (value) => _validateRequired(value, title),
          ),
        ),
      ],
    );
  }
}
