import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool dailyReminder = false;
  bool oneDayBeforeReminder = false;
  bool oneHourBeforeReminder = false;

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
  }

  void _scheduleNotifications() {
    DateTime eventTime = DateTime.now().add(Duration(days: 5));

    if (dailyReminder) {
      NotificationService.scheduleDailyNotification(eventTime.hour, eventTime.minute);
    }

    if (oneDayBeforeReminder) {
      DateTime oneDayBefore = eventTime.subtract(const Duration(days: 1));
      NotificationService.scheduleNotification(oneDayBefore, 9, 0, 'Reminder', 'Event starts tomorrow at ${eventTime.hour}:${eventTime.minute}');
    }

    if (oneHourBeforeReminder) {
      DateTime oneHourBefore = eventTime.subtract(const Duration(hours: 1));
      NotificationService.scheduleNotification(oneHourBefore, oneHourBefore.hour, oneHourBefore.minute, 'Reminder', 'Event starts in one hour');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event starts in 5 days'),
                Text('Set a reminder for 11:00 AM'),
              ],
            ),
          ),
          CheckboxListTile(
            title: const Text('Daily at event time'),
            value: dailyReminder,
            onChanged: (value) {
              setState(() {
                dailyReminder = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('One day before, 9AM'),
            value: oneDayBeforeReminder,
            onChanged: (value) {
              setState(() {
                oneDayBeforeReminder = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('One hour before'),
            value: oneHourBeforeReminder,
            onChanged: (value) {
              setState(() {
                oneHourBeforeReminder = value!;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _scheduleNotifications();
                Navigator.pop(context, true);
              },
              child: const Text('Save settings', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin and request permission
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);


    await _requestNotificationPermission();

    tz.initializeTimeZones();
  }

  // Request notification permission
  static Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  // Display a simple notification
  static Future<void> displayNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Custom_Sound',
    );
  }


  static Future<void> scheduleDailyNotification(int hour, int minute) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Reminder',
      'Don\'t forget your event!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
        ),
      ),
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
    );
  }


  static Future<void> scheduleNotification(
      DateTime scheduledTime, int hour, int minute, String title, String body) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  // Helper method to find the next instance of a time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
