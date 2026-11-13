import 'package:flutter/material.dart';
import 'package:safeherven_app/models/app_user.dart';
import 'package:safeherven_app/screens/chat.dart';
import 'package:safeherven_app/screens/help.dart';
import 'package:safeherven_app/screens/places.dart';
import 'package:safeherven_app/screens/home.dart';
import 'package:safeherven_app/screens/wrapper.dart';
import 'package:safeherven_app/services/local_auth_service.dart';

class MenuBottom extends StatefulWidget {
  final int currentIndex;
  const MenuBottom({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<MenuBottom> createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StreamBuilder<AppUser?>(
              initialData: LocalAuthService.instance.currentUser,
              stream: LocalAuthService.instance.authStateChanges,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Wrapper();
                }
                return HomeScreen(user: snapshot.data!);
              },
            ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PlacesScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HelpScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2545).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0B2545),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded),
            label: 'Locais',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_rounded),
            label: 'Ajuda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}


