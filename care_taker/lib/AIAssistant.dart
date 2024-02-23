import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'chat_screen.dart';

class AIAssistant extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    dotenv.load(fileName: ".env");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Your Medical Companion"),
      ),
      body: const ChatScreen(),
    );
  }
}
