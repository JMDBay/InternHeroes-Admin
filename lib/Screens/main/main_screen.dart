import 'package:flutter_auth/controllers/MenuAppController.dart';
import 'package:flutter_auth/models/RecentFile.dart';
import 'package:flutter_auth/responsive.dart';
import 'package:flutter_auth/Screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_auth/Screens/main/components/side_menu.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuAppController(), // Provide the MenuAppController
      child: Consumer<MenuAppController>(
        builder: (context, menuController, _) => Scaffold(
          key: menuController.scaffoldKey,
          drawer: SideMenu(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // We want this side menu only for large screen
                if (Responsive.isDesktop(context))
                  Expanded(
                    // default flex = 1
                    // and it takes 1/6 part of the screen
                    child: SideMenu(),
                  ),
                Expanded(
                  // It takes 5/6 part of the screen
                  flex: 5,
                  child: DashboardScreen(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
