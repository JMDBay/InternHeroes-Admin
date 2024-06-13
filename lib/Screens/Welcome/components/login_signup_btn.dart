import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import '../../Signup/signup_screen.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonHeight = 50.0; // Set the button height here

    return Column(
      children: [
        SizedBox(
          width: double.infinity, // Make the button as wide as possible
          height: buttonHeight, // Match the height of the login button
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
            child: Text(
              "Login".toUpperCase(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity, // Make the button as wide as possible
          height: buttonHeight, // Match the height of the login button
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color:
                    Colors.yellow[800]!, // Set the border color to yellow[800]
              ),
              backgroundColor: kPrimaryLightColor,
            ),
            child: Text(
              "Sign Up".toUpperCase(),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
