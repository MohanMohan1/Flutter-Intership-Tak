import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReminderHome(),
    );
  }
}

class ReminderHome extends StatefulWidget {
  @override
  _ReminderHomeState createState() => _ReminderHomeState();
}

class _ReminderHomeState extends State<ReminderHome> {
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? selectedDay;
  TimeOfDay? selectedTime;
  String? selectedActivity;

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep'
  ];

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification() async {
    if (selectedDay != null && selectedTime != null && selectedActivity != null) {
      var scheduledNotificationDateTime = _nextInstanceOfSelectedTime();
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        'Channel for reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await localNotificationsPlugin.schedule(
        0,
        'Reminder',
        selectedActivity,
        scheduledNotificationDateTime,
        platformChannelSpecifics,
      );
    }
  }

  DateTime _nextInstanceOfSelectedTime() {
    final now = DateTime.now();
    final selectedDayOfWeek = daysOfWeek.indexOf(selectedDay!) + 1;
    final nextInstance = DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute);

    // Calculate the next instance of the selected time and day
    if (nextInstance.isBefore(now) || now.weekday != selectedDayOfWeek) {
      int daysToAdd = selectedDayOfWeek - now.weekday;
      if (daysToAdd < 0) daysToAdd += 7;
      return nextInstance.add(Duration(days: daysToAdd));
    }
    return nextInstance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Day'),
              value: selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              },
              items: daysOfWeek.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: Text(selectedTime == null
                  ? 'Select Time'
                  : 'Selected Time: ${selectedTime!.format(context)}'),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              hint: Text('Select Activity'),
              value: selectedActivity,
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivity = newValue;
                });
              },
              items: activities.map((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
