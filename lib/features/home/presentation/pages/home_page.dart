import 'package:face_locker/core/services/user_service.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_list_page.dart';
import 'package:face_locker/features/profile/presentation/pages/profile_page.dart';
import 'package:face_locker/features/qrcode/presentation/pages/qrcode_page.dart';
import 'package:face_locker/features/session/presentation/pages/my_session_page.dart';
import 'package:face_locker/features/statistics/presentation/pages/stats_overview_pages.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.userService});

  final UserService? userService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late UserService _userService;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  void _onNavChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _userService = widget.userService ?? UserService();
    _initializePages();
  }

  void _initializePages() {
    if (_userService.isAdmin) {
      _pages = [
        const LockerListPage(),
        const StatsOverviewPages(),
        const ProfilePage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.storage),
          label: 'Management',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Stat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
      ];
    } else {
      _pages = [
        const MySessionPage(),
        const QrcodePage(),
        const ProfilePage(),
      ];
      _navItems = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Sessions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_2),
          label: 'QR Code',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey[400],
        items: _navItems,
      ),
    );
  }
}
