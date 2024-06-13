import 'package:flutter/material.dart';

import 'package:flutter_auth/Screens/Chats/finalchatpage.dart';
import 'package:flutter_auth/Screens/KnowledgeResource/combinedknowledgeresource.dart';

import 'package:flutter_auth/Screens/UserList/userlist.dart';
import 'package:flutter_auth/Screens/main/main_screen.dart';
import 'package:flutter_auth/Screens/EditProfile/editprofile.dart'; // Import EditProfileScreen
// Import KnowledgeResourcePage
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // Set background color for the Drawer
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent, // Set black background color
              ),
              child: Container(
                height: 100, // Set desired height
                width: double.infinity, // Take up full width
                child: Image.asset(
                  "assets/images/ihlogo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            DrawerListTile(
              title: "DashBoard",
              svgSrc: "assets/icons/menu_dashboard.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
            ),
            DrawerListTile(
              title: "Posts",
              svgSrc: "assets/icons/menu_tran.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KnowledgeResourceAndCoursesPage()),
                );
              },
            ),
            DrawerListTile(
              title: "Users",
              svgSrc: "assets/icons/menu_task.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserList()),
                );
              },
            ),
            DrawerListTile(
              title: "Chat",
              svgSrc: "assets/icons/menu_doc.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CombinedPage()),
                );
              },
            ),
            DrawerListTile(
              title: "Notification",
              svgSrc: "assets/icons/menu_notification.svg",
              press: () {},
            ),
            DrawerListTile(
              title: "Profile",
              svgSrc: "assets/icons/menu_profile.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen()), // Navigate to EditProfileScreen
                );
              },
            ),
            DrawerListTile(
              title: "Settings",
              svgSrc: "assets/icons/menu_setting.svg",
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(
            Colors.black, BlendMode.srcIn), // Change SVG color to black
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black), // Change text color to black
      ),
    );
  }
}
