import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors/sensors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _stepsCount = 0;
  int _goalStepsCount = 10000;
  double _progressPercentage = 0.0;
  bool _goalReached = false;

  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
    _requestPermissions();
  }

  @override
  void dispose() {
    super.dispose();
    accelerometerEvents.drain();
  }

  Future<void> _initLocalNotifications() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future<void> _showNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        importance: Importance.high, priority: Priority.high);
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
        0,
        'Congratulations!',
        'You have reached your goal of $_goalStepsCount steps!',
        platformChannelSpecifics,
        payload: 'goal_notification');
  }

  Future<void> _onSelectNotification(String? payload) async {
    if (payload == 'goal_notification') {
      setState(() {
        _goalReached = true;
        _stepsCount = 0;
        _progressPercentage = 0.0;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      accelerometerEvents.listen((AccelerometerEvent event) {
        final double y = event.y;
        if (y > 10) {
          setState(() {
            _stepsCount++;
            _progressPercentage = _stepsCount / _goalStepsCount;
            if (_progressPercentage >= 1.0 && !_goalReached) {
              _goalReached = true;
              _showNotification();
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Steps Walked:',
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$_stepsCount',
              style: const TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200.0,
              width: 200.0,
              child: CircularProgressIndicator(
                strokeWidth: 8.0,
                value: _progressPercentage,
                backgroundColor: Colors.grey,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Goal: $_goalStepsCount steps',
              style: const TextStyle(
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              child: const Text('Set Goal'),
              onPressed: () async {
                int newGoal = 0;
                final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Set Goal'),
                      content: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          newGoal = int.tryParse(value) ?? 0;
                        },
                      ),
                      actions: [
                        ElevatedButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () {
                            Navigator.pop(context, newGoal);
                          },
                        ),
                      ],
                    );
                  },
                );
                if (result != null) {
                  setState(() {
                    _goalStepsCount = result;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
