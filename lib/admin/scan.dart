// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:intl/intl.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

List<int> tagValue = [];

class _ScanScreenState extends State<ScanScreen> {
  final _tagValueController = TextEditingController();

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

      // Record the timestamp in Firestore based on the NFC identifier
      await FirebaseFirestore.instance
          .collection('User')
          .where('nfcIdentifier', isEqualTo: tagValue)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          // NFC identifier found, record the timestamp
          querySnapshot.docs.forEach((DocumentSnapshot document) {
            document.reference.collection('timestamps').add({
              'timestamp': DateTime.now(),
            });
          });

          // Show success message
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Success!'),
                content: Text('Attendance recorded successfully!'),
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
          // NFC identifier not found
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('NFC identifier not found!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
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

  String checkIn = "--/--";
  String checkOut = "--/--";

  _checkTagValue() async {
    if (_tagValueController != null && _tagValueController.text.isNotEmpty) {
      String tagValue = _tagValueController.text;

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("User")
          .where('nfcIdentifier', isEqualTo: tagValue)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("User")
          .doc(snap.docs[0].id)
          .collection("Attendance")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      try {
        String checkIn = snap2['checkIn'];

        setState(() {
          checkOut = DateFormat('HH:mm').format(DateTime.now());
        });

        // Update checkout
        await FirebaseFirestore.instance
            .collection("User")
            .doc(snap.docs[0].id)
            .collection("Attendance")
            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
            .update({
          'date': Timestamp.now(),
          'checkIn': checkIn,
          'checkOut': DateFormat('HH:mm').format(DateTime.now())
        });
      } catch (e) {
        setState(() {
          checkIn = DateFormat('HH:mm').format(DateTime.now());
        });

        // Update check in
        await FirebaseFirestore.instance
            .collection("User")
            .doc(snap.docs[0].id)
            .collection("Attendance")
            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
            .set({
          'date': Timestamp.now(),
          'checkIn': DateFormat('HH:mm').format(DateTime.now()),
          'checkOut': "--/--",
        });
      }

      _tagValueController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                child: Text('Scan Card'),
                onPressed: () {
                  _checkTagValue();
                },
              ),
            ),
            Text(
              'NFC Card Identifier:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              _tagValueController.text.isNotEmpty
                  ? _tagValueController.text
                  : 'Not scanned yet',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
