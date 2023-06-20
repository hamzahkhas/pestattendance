// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNewBookingPage extends StatefulWidget {
  const CreateNewBookingPage({Key? key}) : super(key: key);

  @override
  State<CreateNewBookingPage> createState() => _CreateNewBookingPageState();
}

class _CreateNewBookingPageState extends State<CreateNewBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final bookingDetailsController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;

  CollectionReference bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Date:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () {
                  _selectDate(context);
                },
                child: Text(
                  '${selectedDate.toLocal()}'.split(' ')[0],
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Service Time:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<TimeOfDay>(
                value: selectedTime,
                items: _getAvailableTimeSlots(),
                onChanged: (value) {
                  setState(() {
                    selectedTime = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a service time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Booking Details:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: bookingDetailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter booking details';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveBooking();
                  }
                },
                child: Text('Submit Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<TimeOfDay>> _getAvailableTimeSlots() {
    final availableSlots = <DropdownMenuItem<TimeOfDay>>[];
    final currentTime = TimeOfDay.now();
    final maxSlotsPerHour = 2;

    for (int hour = currentTime.hour; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 60 ~/ maxSlotsPerHour) {
        final time = TimeOfDay(hour: hour, minute: minute);
        final formattedTime = time.format(context);

        availableSlots.add(
          DropdownMenuItem<TimeOfDay>(
            value: time,
            child: Text(formattedTime),
          ),
        );
      }
    }

    return availableSlots;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void saveBooking() {
    final serviceDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final bookingDetails = bookingDetailsController.text;

    bookingsCollection.add({
      'serviceDate': serviceDateTime,
      'bookingDetails': bookingDetails,
    }).then((value) {
      // Booking saved successfully
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Booking Submitted'),
            content: Text('Your booking has been saved.'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      // Error occurred while saving booking
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while saving the booking.'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }
}
