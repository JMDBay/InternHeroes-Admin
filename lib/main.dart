import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter_auth/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with custom options
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: " AIzaSyBSviAfXdUfHWwjRXlP1BG9l_wWnQ0GtqM",
      projectId: "internheroes-49040",
      messagingSenderId: "679588831210",
      appId: "1:679588831210:web:2cd922e54255dc9d1fdc93",
      storageBucket: "internheroes-49040.appspot.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor,
            shape: const StadiumBorder(),
            minimumSize: const Size(100, 70), // Adjust the size here
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kPrimaryLightColor,
          iconColor: kPrimaryColor,
          prefixIconColor: kPrimaryColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white, // Set the surface color to white
          shadowColor:
              Colors.grey.withOpacity(0.2), // Optional: Set shadow color
          elevation: 4, // Optional: Set elevation
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Optional: Set border radius
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
