import 'dart:convert';
import 'package:event_count_app/eventdetail.dart';
import 'package:event_count_app/newevent.dart';
import 'package:event_count_app/notificationsettingscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleDarkMode;

  HomeScreen({required this.isDarkMode, required this.toggleDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }
  int getCountdownDays(DateTime eventDate) {
    final now = DateTime.now();
    return eventDate.difference(now).inDays;
  }
  Future<void> saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    List<Map<String, dynamic>> eventsToSave = events.map((event) {
      return {
        "title": event["title"],
        "date": event["date"].toString(),
        "description": event["description"],
        "enableNotification":
            event["enableNotification"],
      };
    }).toList();

    String eventsJson =
        jsonEncode(eventsToSave);
    await prefs.setString('events', eventsJson);
  }
  Future<void> loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsJson =
        prefs.getString('events');

    if (eventsJson != null) {
      List<dynamic> decodedEvents =
          jsonDecode(eventsJson);
      setState(() {

        events = decodedEvents.map((e) {
          return {
            "title": e["title"],
            "date":
                DateTime.parse(e["date"]),
            "description": e["description"],
            "enableNotification":
                e["enableNotification"],
          };
        }).toList();
      });
    }
  }
  Future<void> navigateToAddEventScreen() async {
    final newEvent = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => NewEventPage(),
      ),
    );

    if (newEvent != null) {
      setState(() {
        events.add(newEvent);
      });
      await saveEvents();


      if (newEvent["enableNotification"] == true) {
        bool? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationSettingsScreen(),
          ),
        );

        if (result != null && result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification settings saved!')),
          );
        }
      }
    }
  }
  void deleteEvent(int index) async {
    setState(() {
      events.removeAt(index);
    });
    await saveEvents();
  }
  void navigateToEventDetailScreen(
      Map<String, dynamic> event, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          initialEventName: event["title"], // Pass event name
          initialEventDate: event["date"], // Pass event date
          onDelete: (String eventName) {
            setState(() {
              events.removeAt(index);
            });
            saveEvents();
          },
          onEdit: (String updatedName, DateTime updatedDate) {
            setState(() {
              events[index] = {
                "title": updatedName,
                "date": updatedDate,
                "description":
                    event["description"],
                "enableNotification": event[
                    "enableNotification"],
              };
            });
            saveEvents();
          },
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Countdown"),
        actions: [
          IconButton(
            icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.toggleDarkMode,
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final daysLeft = getCountdownDays(
              event["date"]);

          return Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4.0, horizontal: 8.0),
            child: Card(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0),
              ),
              elevation: 4.0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 16.0),
                title: Text(
                  event["title"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(
                      top: 4.0),
                  child: Text(
                    'Date: ${event["date"].toLocal().toString().split(' ')[0]}\n'
                    'Countdown: $daysLeft days',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteEvent(index),
                ),
                onTap: () => navigateToEventDetailScreen(
                    event, index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: navigateToAddEventScreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
