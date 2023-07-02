import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/model/user.dart';

class UserDetailsScreen extends StatefulWidget {
  final String username;

  UserDetailsScreen({required this.username});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(User.docId)
        .get();

    if (documentSnapshot.exists) {
      setState(() {
        userData = documentSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red.shade800,
          leading: Icon(Icons.arrow_back_ios_new),
          title: Text('User Details'),
        ),
        body: userData != null
            ? ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  buildDetailRow('Username', widget.username),
                  buildDetailRow('Password', '*****'),
                  buildDetailRow('First Name', userData!['firstname']),
                  buildDetailRow('Last Name', userData!['lastname']),
                  buildDetailRow('Role', userData!['role']),
                  buildDetailRow('Contact No', userData!['contact']),
                  buildDetailRow('Address', userData!['address']),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class UserDetailScreen extends StatefulWidget {
  final String username;

  UserDetailScreen({required this.username});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final FirebaseFirestore userdetails = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('User Details'),
      ),
      body: Text("Users details of " + widget.username),
    );
  }
}
