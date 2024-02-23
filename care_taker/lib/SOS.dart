import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({Key? key}) : super(key: key);

  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final contacts = <String>[];
  bool isSosEnabled = false;
  bool isCallingEnabled = true;
  bool isSMSEnabled = true;
  bool _callPermissionGranted = false;
  bool _smsPermissionGranted = false;
  Timer? _sosTimer;
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    accelerometerEvents.listen((event) {
      if (isSosEnabled &&
          (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15)) {
        if (_sosTimer == null || !_sosTimer!.isActive) {
          if (isSMSEnabled) {
            _getCurrentLocation().then((position) {
              sendingSMS(
                  'Help! I need assistance. \n My location is ${position.latitude},${position.longitude}.',
                  contacts);
            });
          }
          if (isCallingEnabled) {
            _makePhoneCall(contacts.first);
          }
          _sosTimer = Timer(const Duration(seconds: 60), () {
            _sosTimer = null;
          });
        }
      }
    });
  }

  Future<void> _requestPermissions() async {
    final callPermission = await Permission.phone.request();
    final smsPermission = await Permission.sms.request();
    final locationPermission = await Permission.location.request();
    setState(() {
      _callPermissionGranted = callPermission == PermissionStatus.granted;
      _smsPermissionGranted = smsPermission == PermissionStatus.granted;
    });
  }

  Future<Position> _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator();
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void sendingSMS(String msg, List<String> listRecipients) async {
    if (_smsPermissionGranted) {
      try {
        String sendResult = await sendSMS(
            message: msg, recipients: listRecipients, sendDirect: true);
        print(sendResult);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    if (_callPermissionGranted) {
      try {
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      } catch (e) {
        throw 'Could not launch $phoneNumber';
      }
    }
  }

  void _showAddContactDialog() {
    String newContact = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          keyboardType: TextInputType.phone,
          onChanged: (value) => newContact = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                contacts.add(newContact);
              });
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SOS',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enable Calling'),
                Switch(
                  value: isCallingEnabled,
                  onChanged: (value) {
                    setState(() {
                      isCallingEnabled = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enable SMS'),
                Switch(
                  value: isSMSEnabled,
                  onChanged: (value) {
                    setState(() {
                      isSMSEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _showAddContactDialog,
              child: const Text('+ Contacts'),
            ),
            const SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 95,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(contacts[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          contacts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'SOS is ${isSosEnabled ? 'enabled' : 'disabled'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isSosEnabled = !isSosEnabled;
                });
              },
              child: Text(isSosEnabled ? 'Disable SOS' : 'Enable SOS'),
            ),
          ],
        ),
      ),
    );
  }
}
