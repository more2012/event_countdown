import 'package:event_count_app/notificationsettingscreen.dart';
import 'package:flutter/material.dart';

class NewEventPage extends StatefulWidget {
  const NewEventPage({super.key});

  @override
  _NewEventPageState createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final TextEditingController _eventNameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _pushNotificationsEnabled = false;


  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }


  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Event name input field
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                hintText: 'Enter Event Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date input field
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    labelText: _selectedDate == null
                        ? 'Date'
                        : '${_selectedDate!.toLocal()}'.split(' ')[0],
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time input field
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    labelText: _selectedTime == null
                        ? 'Time'
                        : _selectedTime!.format(context),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable Push Notifications'),
                Switch(
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Create Event button
            ElevatedButton(
              onPressed: () {
                if (_eventNameController.text.isNotEmpty &&
                    _selectedDate != null) {
                  // Combine date and time, defaulting to 12:00 AM if no time is selected
                  final DateTime eventDateTime = _selectedTime != null
                      ? _combineDateAndTime(_selectedDate!, _selectedTime!)
                      : _selectedDate!;

                  final newEvent = {
                    "title": _eventNameController.text,
                    "date": eventDateTime,
                    "description": "",
                  };

                  Navigator.pop(context, newEvent);


                  if (_pushNotificationsEnabled) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationSettingsScreen(),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
