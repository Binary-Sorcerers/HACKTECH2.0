import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MedicationReminder {
  String medicineName;
  TimeOfDay time;
  DateTime date;
  String tabletType; // New field for tablet type

  MedicationReminder({
    required this.medicineName,
    required this.time,
    required this.date,
    required this.tabletType,
  });
}

class MedicPage extends StatefulWidget {
  const MedicPage({Key? key}) : super(key: key);

  @override
  _MedicPageState createState() => _MedicPageState();
}

class _MedicPageState extends State<MedicPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _medicineName = '';
  TimeOfDay _timeOfDay = TimeOfDay.now();
  DateTime _dateTime = DateTime.now();
  List<MedicationReminder> _medicationReminders = [];

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle notification tap event here
  }

  Future<void> _scheduleNotification(
      String medicineName, TimeOfDay time, DateTime date) async {
    var scheduledDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute, 0, 0, 0);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'medic_notifications', 'Medic Notifications', 'Medic Notifications',
        importance: Importance.high, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics =
        const IOSNotificationDetails(sound: 'default', presentAlert: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        _medicationReminders.length + 1,
        'Medication Reminder',
        'Time to take $medicineName',
        scheduledDateTime,
        platformChannelSpecifics);

    // Schedule an alarm or set alongside the notification
    // ignore: prefer_typing_uninitialized_variables
    var tz;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        _medicationReminders.length + 1,
        'Medication Alarm',
        'It\'s time to take $medicineName',
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medic_alarms',
            'Medic Alarms',
            'Medic Alarms',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: false,
            channelShowBadge: false,
          ),
          iOS: IOSNotificationDetails(
            sound: 'default',
            presentAlert: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  void _addReminder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? tabletType; // Variable to store the selected tablet type
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: tabletType,
                decoration: const InputDecoration(
                  labelText: 'Tablet Type',
                ),
                items: [
                  'Injection',
                  'Tablet',
                  'Syrup',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tabletType = value;
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  _showDateTimePicker();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Reminder Time:',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      '${_timeOfDay.format(context)} on ${_dateTime.day}/${_dateTime.month}/${_dateTime.year}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                var reminder = MedicationReminder(
                  medicineName: _medicineName,
                  time: _timeOfDay,
                  date: _dateTime,
                  tabletType: tabletType ?? '',
                );
                setState(() {
                  _medicationReminders.add(reminder);
                });
                _scheduleNotification(
                    reminder.medicineName, reminder.time, reminder.date);
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _removeReminder(int index) {
    setState(() {
      _medicationReminders.removeAt(index);
    });
    // Cancel the scheduled notification and alarm for the removed reminder
    var notificationId = index + 1;
    flutterLocalNotificationsPlugin.cancel(notificationId);
    flutterLocalNotificationsPlugin
        .cancel(notificationId + 1000); // Assuming alarm IDs are offset by 1000
  }

  Future<void> _showDateTimePicker() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (pickedDate != null && pickedDate != _dateTime) {
      setState(() {
        _dateTime = pickedDate;
      });
    }
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: _timeOfDay);
    if (pickedTime != null && pickedTime != _timeOfDay) {
      setState(() {
        _timeOfDay = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reminders'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
              ),
              onChanged: (value) {
                setState(() {
                  _medicineName = value;
                });
              },
              style: const TextStyle(), // Updated line
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: () {
                _showDateTimePicker();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Reminder Time:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    '${_timeOfDay.format(context)} on ${_dateTime.day}/${_dateTime.month}/${_dateTime.year}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addReminder,
            child: const Text('Add Reminder'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _medicationReminders.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(_medicationReminders[index].medicineName),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removeReminder(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      _medicationReminders[index].medicineName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tablet Type: ${_medicationReminders[index].tabletType}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          '${_medicationReminders[index].time.format(context)} on ${_medicationReminders[index].date.day}/${_medicationReminders[index].date.month}/${_medicationReminders[index].date.year}',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
