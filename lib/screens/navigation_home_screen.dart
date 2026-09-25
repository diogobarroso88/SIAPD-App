import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';
import 'home_page.dart';
import 'new_observation_page.dart';
import 'sent_observations_page.dart';
import 'offline_observations_page.dart';
import 'profile_page.dart';


class NavigationHomeScreen extends StatefulWidget {
  const NavigationHomeScreen({super.key});

  @override
  State<NavigationHomeScreen> createState() =>
      _NavigationHomeScreenState();
}

class _NavigationHomeScreenState
    extends State<NavigationHomeScreen> {
  int _currentIndex = 0;

  List<Widget> _pages = [];

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return '';
      case 1:
        return '';
      case 2:
        return '';
      case 3:
        return '';
      default:
        return '';
    }
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddObservation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewObservationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    _pages = [
      const HomePage(),
      const SentObservationsPage(),
      const OfflineObservationsPage(),
      if (user != null)
        ProfilePage(user: user)
      else
        const Center(
          child: CircularProgressIndicator(),
        ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
      ),

      drawer: AppDrawer(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

      body: _pages[_currentIndex],

      bottomNavigationBar: _buildBottomNavigationBar(),

      floatingActionButton: FloatingActionButton(
        onPressed: _onAddObservation,
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar() {

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavigationItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: '',
              index: 0,
            ),

            _buildNavigationItem(
              icon: Icons.cloud_upload_outlined,
              activeIcon: Icons.cloud_upload,
              label: '',
              index: 1,
            ),

            const SizedBox(width: 60),

            _buildNavigationItem(
              icon: Icons.cloud_off_outlined,
              activeIcon: Icons.cloud_off,
              label: '',
              index: 2,
            ),

            _buildNavigationItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: '',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigationItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}