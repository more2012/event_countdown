import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'newevent.dart';
class Event {
  final String name;
  final DateTime dateTime;

  Event(this.name, this.dateTime);
}

class EventDetailScreen extends StatefulWidget {
  final String initialEventName;
  final DateTime initialEventDate;
  final Function(String) onDelete;
  final Function(String, DateTime) onEdit;

  EventDetailScreen({
    required this.initialEventName,
    required this.initialEventDate,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late String eventName;
  late DateTime eventDate;
  late Timer _timer;
  Duration _timeRemaining = Duration();

  @override
  void initState() {
    super.initState();
    // Initialize mutable state with the passed event details
    eventName = widget.initialEventName;
    eventDate = widget.initialEventDate;
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = eventDate.difference(DateTime.now());
      });
    });
  }

  String _formatCountdown() {
    if (_timeRemaining.isNegative) {
      return "Event has passed!";
    }

    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return "$days days $hours hours $minutes minutes $seconds seconds";
  }

  bool _hasEventPassed() {
    return DateTime.now().isAfter(eventDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(
          Icons.calendar_month,
          size: 30,
          color: Colors.black,
        ),
        title: Text('Event Countdown'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${DateFormat.yMMMMd().format(eventDate)} at ${DateFormat.jm().format(eventDate)}',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.timer, size: 24, color: Colors.black54),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _hasEventPassed()
                        ? 'Event has passed!'
                        : 'Countdown: ${_formatCountdown()}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Edit or Delete Event Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Event Options"),
                        content:
                            Text("Do you want to delete or edit this event?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              final editedEvent = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewEventPage(
                                    key: widget.key,
                                  ),
                                ),
                              );


                              if (editedEvent != null) {
                                widget.onEdit(
                                    editedEvent["title"],
                                    editedEvent[
                                        "date"]);
                                setState(() {
                                  eventName = editedEvent["title"];
                                  eventDate = editedEvent["date"];
                                });
                              }

                              Navigator.pop(
                                  context);
                            },
                            child: Text("Edit"),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onDelete(eventName);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Edit or Delete Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
