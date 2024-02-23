import 'package:care_taker/SOS.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
// import 'AIAssistant.dart';
//import 'Vitals.dart';
import 'homepage.dart';
import 'medic.dart';
import 'smartwearable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Care Taker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.white70,
            fontStyle: FontStyle.normal,
            fontSize: 22,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  // ignore: prefer_final_fields
  List<Widget> _pages = [
    const HomePage(),
    const MedicPage(),
    const SOSPage(),
    SmartWearablePage(),
    // // const Vitals(),
    // AIAssistant(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  void _loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('selectedIndex') ?? 0;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _saveSession(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedIndex', index);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _saveSession(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Care Taker',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.shifting,
        selectedFontSize: 15,
        unselectedIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        selectedIconTheme: const IconThemeData(color: Colors.black),
        selectedItemColor: Colors.black,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        backgroundColor: Colors.deepPurple,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership_sharp),
            label: 'Home',
            backgroundColor: Colors.deepPurple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            label: 'Medic',
            backgroundColor: Colors.deepPurple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_outlined),
            label: 'SOS',
            backgroundColor: Colors.deepPurple,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.monitor_heart_outlined),
          //   label: 'Vitals',
          //   backgroundColor: Colors.deepPurple,
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.adb_outlined),
            label: 'smartwearable',
            backgroundColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Page'),
    );
  }
}

class Medic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Medication Remainder'),
    );
  }
}
