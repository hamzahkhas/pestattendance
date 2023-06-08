import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pestattendance/model/user.dart';

class NFCScanScreen extends StatefulWidget {
  @override
  _NFCScanScreenState createState() => _NFCScanScreenState();
}

class _NFCScanScreenState extends State<NFCScanScreen> {
  String _scanResult = 'Scan your card';
  bool _isScanning = false;

  Future<void> _scanNFC() async {
    setState(() {
      _scanResult = 'Scan in progress...';
      _isScanning = true;
    });

    String response;
    try {
      //response = await FlutterNfcReader.read;
    } catch (e) {
      response = e.toString();
    }

    setState(() {
      // _scanResult = response;
      _isScanning = false;
    });

    if (_scanResult != null && _scanResult.isNotEmpty) {
      saveAttendanceToFirestore(_scanResult);
    }
  }

  Future<void> saveAttendanceToFirestore(String cardId) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(User.docId)
          .collection('Attendance')
          .add({
        'cardId': cardId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Attendance saved successfully!');
    } catch (e) {
      print('Failed to save attendance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NFC Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_scanResult),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text(_isScanning ? 'Scanning...' : 'Scan NFC'),
              onPressed: _isScanning ? null : _scanNFC,
            ),
          ],
        ),
      ),
    );
  }
}
