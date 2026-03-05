import 'package:flutter/material.dart';
import 'package:laptopharbor/ui/screens/user/contact_screen.dart';
import 'package:line_icons/line_icons.dart';

import '../screens/user/home_screen.dart';
import '../screens/user/product_list_screen.dart';
import '../screens/user/orders_list_screen.dart';
import '../screens/user/support_screen.dart';
import '../screens/user/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      case 1:
        page = ProductListScreen();
        break;
      case 2:
        page = const OrdersListScreen();
        break;
      case 3:
        page = const ContactScreen();
        break;
      case 4:
        page = const SupportScreen();
        break;
      case 5:
        page = const ProfileScreen();
        break;
      default:
        page = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _navigate(context, i),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LineIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.shoppingBag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.shoppingCart),
            label: 'Orders',
          ),
           BottomNavigationBarItem(
            icon: Icon(LineIcons.phone),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.headset),
            label: 'Support',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
