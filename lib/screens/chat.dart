import 'package:flutter/material.dart';
import 'package:safeherven_app/shared/chat.dart';
import 'package:safeherven_app/shared/bottom.dart';
import 'package:safeherven_app/shared/appbar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SafeHervenAppBar("Chat de Apoio", isHome: false),
      bottomNavigationBar: const MenuBottom(currentIndex: 3),
      body: const Center(
        child: Chat(),
      ),
    );
  }
}
