import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordRequirementsMet = true;
  bool _emailValid = true;

  final _passwordRequirementText =
      "Password must be 8 characters, 1 lowercase, 1 uppercase, 1 digit, and 1 special character.";

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize Firebase within the SignUpForm widget
    Firebase.initializeApp(); // Initialize Firebase
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _validatePassword(String value) {
    final isValidPassword = _checkPasswordRequirements(value);
    if (_passwordRequirementsMet != isValidPassword) {
      setState(() {
        _passwordRequirementsMet = isValidPassword;
      });
    }
  }

  void _validateEmail(String value) {
    final isValidEmail = value.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
    if (_emailValid != isValidEmail) {
      setState(() {
        _emailValid = isValidEmail;
      });
    }
  }

  void _validateConfirmPassword(String value) {
    final isValidPassword = _confirmPasswordController.text == value &&
        _checkPasswordRequirements(value);
    setState(() {
      _passwordRequirementsMet = isValidPassword;
    });
  }

  bool _checkPasswordRequirements(String value) {
    final passwordRegex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(value);
  }

  void _showPasswordRequirementsSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_passwordRequirementText),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _signUp() async {
    if (!_passwordRequirementsMet || !_emailValid) {
      _showPasswordRequirementsSnackBar(context);
      return;
    }

    try {
      print('Attempting to sign up...');

      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _confirmPasswordController.text,
      );

      // Save additional user data to Firestore
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'isAdmin': true, // Set isAdmin to true
        // Add more fields as needed
      });

      print(
          'User signed up successfully! User ID: ${userCredential.user!.uid}');

      // Optionally, navigate to another screen after sign up
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } catch (e) {
      print('Error signing up: $e');
      // Handle error, e.g., show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: "First Name",
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Icon(Icons.person,
                            color: Color.fromARGB(255, 238, 177, 34)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: "Last Name",
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(defaultPadding),
                        child: Icon(Icons.person,
                            color: Color.fromARGB(255, 238, 177, 34)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: _emailController,
            onChanged: _validateEmail,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              hintText: "Your email",
              errorText: _emailValid ? null : "Please enter a valid email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child:
                    Icon(Icons.email, color: Color.fromARGB(255, 238, 177, 34)),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            textInputAction: TextInputAction.next,
            obscureText: _obscurePassword,
            cursorColor: kPrimaryColor,
            onChanged: _validatePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              hintText: "Your password",
              errorText:
                  _passwordRequirementsMet ? null : _passwordRequirementText,
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child:
                    Icon(Icons.lock, color: Color.fromARGB(255, 238, 177, 34)),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: _togglePasswordVisibility,
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Color.fromARGB(255, 238, 177, 34)),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            textInputAction: TextInputAction.done,
            obscureText: _obscureConfirmPassword,
            controller: _confirmPasswordController,
            onChanged: _validateConfirmPassword,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              hintText: "Confirm password",
              errorText: _passwordRequirementsMet
                  ? null
                  : "Passwords do not match or don't meet requirements",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child:
                    Icon(Icons.lock, color: Color.fromARGB(255, 238, 177, 34)),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: _toggleConfirmPasswordVisibility,
                  icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Color.fromARGB(255, 238, 177, 34)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: defaultPadding, top: 4.0),
            child: Text(
              _passwordRequirementText,
              style: TextStyle(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity, // Make the button as wide as possible
            child: ElevatedButton(
              onPressed: _signUp,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 238, 177, 34)),
              ),
              child: Text(
                "Sign Up".toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
