import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  EditUserScreen({required this.userId, required this.userData});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _contactNoController;
  late TextEditingController _addressController;
  String _selectedRole = '';

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userData['username']);
    _firstNameController =
        TextEditingController(text: widget.userData['firstName']);
    _lastNameController =
        TextEditingController(text: widget.userData['lastName']);
    _contactNoController =
        TextEditingController(text: widget.userData['contact']);
    _addressController =
        TextEditingController(text: widget.userData['address']);
    _selectedRole = widget.userData['role'];
  }

  void _updateUserInformation() {
    FirebaseFirestore.instance.collection('User').doc(widget.userId).update({
      'username': _usernameController.text,
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'role': _selectedRole,
      'contactNo': _contactNoController.text,
      'address': _addressController.text,
    }).then((_) {
      Navigator.pop(context);
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update user information.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit User'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              DropdownButton<String>(
                value: _selectedRole,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  }
                },
                items: ['Admin', 'Technician', 'Manager'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: _contactNoController,
                decoration: InputDecoration(labelText: 'Contact No'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  _updateUserInformation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
