import 'package:flutter_auth/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/controllers/MenuAppController.dart';
import 'package:flutter_auth/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            "Dashboard",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        Expanded(child: SearchField()),
        ProfileCard()
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<void> _confirmLogout() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Logout'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to logout?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Dismiss the dialog and return false
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore
          .collection('admin')
          .doc(user?.uid)
          .get(), // Use 'admin' collection
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while fetching data
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final Map<String, dynamic>? data =
            snapshot.data?.data() as Map<String, dynamic>?;

        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final fullName = "$firstName $lastName";

        final profileImageUrl =
            data?['profileImageUrl']; // Retrieve profileImageUrl from Firestore

        return Container(
          margin: EdgeInsets.only(left: defaultPadding),
          padding: EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Use conditional rendering to display profile picture
              if (profileImageUrl != null)
                CircleAvatar(
                  radius: 19,
                  backgroundImage: NetworkImage(profileImageUrl),
                )
              else
                Image.asset(
                  "assets/images/profile_pic.png",
                  height: 38,
                ),
              if (!Responsive.isMobile(context))
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding / 2),
                  child: Text(fullName),
                ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: _confirmLogout,
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      // Wrap with Material widget to apply elevation
      elevation: 4, // Set elevation to 4
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search",
          fillColor: Colors.white, // Set background color to white
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          suffixIcon: InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(defaultPadding * 0.75),
              margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: SvgPicture.asset("assets/icons/Search.svg"),
            ),
          ),
        ),
      ),
    );
  }
}
