import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_auth/Screens/main/components/side_menu.dart';

import 'package:image_picker_web/image_picker_web.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late User? currentUser; // Initialize currentUser variable
  File? _imageFile; // Variable to store selected image file
  Uint8List? _imageBytes;
  String firstName = '';
  String lastName = '';
  String email = ''; // Added email field
  String password = ''; // Added password field
  String phoneNumber = ''; // Added phone number field
  String mentorIn = ''; // Added mentor in field
  String companyName = ''; // Added company name field
  String yearOfEmployment = ''; // Added year of employment field

  @override
  void initState() {
    super.initState();
    retrieveCurrentUser(); // Call method to retrieve current user on screen initialization
  }

  void retrieveCurrentUser() {
    FirebaseAuth auth = FirebaseAuth.instance;
    currentUser = auth.currentUser; // Get the current logged-in user

    if (currentUser != null) {
      // If user is logged in, retrieve their profile data
      FirebaseFirestore.instance
          .collection('admin')
          .doc(currentUser!
              .uid) // Use the UID of the current user to get their document
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          // Retrieve and set user details from the document
          var userData = documentSnapshot.data() as Map<String, dynamic>?;

          if (userData != null) {
            // Check if userData is not null
            setState(() {
              firstName = userData['firstName'] ?? 'Not available';
              lastName = userData['lastName'] ?? 'Not available';
              email = userData['email'] ??
                  'Not available'; // Set email from document
              password = '********'; // Set password (masked for security)
              phoneNumber = userData['phoneNumber'] ??
                  'Not available'; // Set phone number from document
              mentorIn = userData['mentorIn'] ??
                  'Not available'; // Set mentor in from document
              companyName = userData['companyName'] ??
                  'Not available'; // Set company name from document
              yearOfEmployment = userData['yearOfEmployment'] ??
                  'Not available'; // Set year of employment from document
            });
          } else {
            setState(() {
              firstName = 'Not available';
              lastName = 'Not available';
              email = 'Not available';
              password = '********';
              phoneNumber = 'Not available';
              mentorIn = 'Not available';
              companyName = 'Not available';
              yearOfEmployment = 'Not available';
            });
            print('User data is null');
          }
        } else {
          setState(() {
            firstName = 'Not available';
            lastName = 'Not available';
            email = 'Not available';
            password = '********';
            phoneNumber = 'Not available';
            mentorIn = 'Not available';
            companyName = 'Not available';
            yearOfEmployment = 'Not available';
          });
          print('Document does not exist for user: ${currentUser!.uid}');
        }
      }).catchError((error) {
        setState(() {
          firstName = 'Error';
          lastName = 'Error';
          email = 'Error';
          password = '********';
          phoneNumber = 'Error';
          mentorIn = 'Error';
          companyName = 'Error';
          yearOfEmployment = 'Error';
        });
        print('Error retrieving user data: $error');
      });
    } else {
      print('No user signed in');
    }
  }

  void saveChanges() async {
    if (_imageFile != null) {
      // Upload image file to Firestore storage
      String fileName = currentUser!.uid + '_profile_image';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await storageReference.putFile(_imageFile!);
      String imageUrl = await storageReference.getDownloadURL();

      // Update profileImageUrl field in Firestore document
      FirebaseFirestore.instance
          .collection('admin')
          .doc(currentUser!.uid)
          .update({'profileImageUrl': imageUrl})
          .then((_) => print('Profile image uploaded and URL saved'))
          .catchError(
              (error) => print('Failed to upload profile image: $error'));
    } else {
      print('No image selected');
    }

    // Update other profile information if needed
    FirebaseFirestore.instance
        .collection('admin')
        .doc(currentUser!.uid)
        .update({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'mentorIn': mentorIn,
          'companyName': companyName,
          'yearOfEmployment': yearOfEmployment,
        })
        .then((_) => print('Changes saved successfully'))
        .catchError((error) => print('Failed to save changes: $error'));
  }

  void editLoginInfo() {
    // Prompt for editing login information
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newEmail = '';
        String oldPassword = '';
        String newPassword = '';
        String confirmNewPassword = '';

        return AlertDialog(
          title: Text('Edit Login Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'New Email'),
                  onChanged: (value) {
                    newEmail = value;
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: 'Old Password'),
                  onChanged: (value) {
                    oldPassword = value;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: 'New Password'),
                  onChanged: (value) {
                    newPassword = value;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration:
                      InputDecoration(labelText: 'Confirm New Password'),
                  onChanged: (value) {
                    confirmNewPassword = value;
                  },
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Implementation of the logic for updating email and password here
                print('New Email: $newEmail');
                print('Old Password: $oldPassword');
                print('New Password: $newPassword');
                print('Confirm New Password: $confirmNewPassword');

                // Call saveChanges method or update logic directly here
                saveLoginInfo(
                    newEmail, oldPassword, newPassword, confirmNewPassword);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void saveLoginInfo(String newEmail, String oldPassword, String newPassword,
      String confirmNewPassword) async {
    try {
      // Check if new email and passwords are not empty and new password matches confirm password
      if (newEmail.isNotEmpty &&
          newPassword.isNotEmpty &&
          newPassword == confirmNewPassword) {
        FirebaseAuth auth = FirebaseAuth.instance;
        User? currentUser = auth.currentUser;

        if (currentUser != null) {
          // Re-authenticate user using old password before updating email and password
          AuthCredential credential = EmailAuthProvider.credential(
              email: currentUser.email!, password: oldPassword);
          await currentUser.reauthenticateWithCredential(credential);

          // Update email in Firebase Auth
          await currentUser.updateEmail(newEmail);

          // Update password in Firebase Auth
          await currentUser.updatePassword(newPassword);

          // Update email in Firestore
          FirebaseFirestore.instance
              .collection('admin')
              .doc(currentUser.uid)
              .update({'email': newEmail})
              .then((_) => print('Email updated in Firestore'))
              .catchError((error) =>
                  print('Error updating email in Firestore: $error'));

          // Show success message or navigate to another screen
          print('Email and password updated successfully');
          // You can also navigate to another screen here if needed
        } else {
          print('No user signed in');
        }
      } else {
        // Show error message for invalid input or mismatched passwords
        print('Invalid input or passwords do not match');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error updating email and password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            child: SideMenu(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
// Change from Column to Row
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      surfaceTintColor: Colors.white,
                      elevation: 10,
                      child: Container(
                        width: double
                            .infinity, // Use double.infinity for the card width
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'General Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              Table(
                                columnWidths: {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(3),
                                },
                                children: [
                                  _buildTableRow('First Name:', firstName,
                                      (value) {
                                    setState(() {
                                      firstName = value;
                                    });
                                  }),
                                  _buildTableRow('Last Name:', lastName,
                                      (value) {
                                    setState(() {
                                      lastName = value;
                                    });
                                  }),
                                  _buildTableRow('Phone Number:', phoneNumber,
                                      (value) {
                                    setState(() {
                                      phoneNumber = value;
                                    });
                                  }),
                                  _buildTableRow('Position:', mentorIn,
                                      (value) {
                                    setState(() {
                                      mentorIn = value;
                                    });
                                  }),
                                  _buildTableRow('Company Name:', companyName,
                                      (value) {
                                    setState(() {
                                      companyName = value;
                                    });
                                  }),
                                  _buildTableRow(
                                      'Year of Employment:', yearOfEmployment,
                                      (value) {
                                    setState(() {
                                      yearOfEmployment = value;
                                    });
                                  }),
                                ],
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  saveChanges(); // Call method to save changes
                                },
                                child: Text('Save Changes'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Add spacing between cards
                  Expanded(
                    flex: 2,
                    child: Card(
                      surfaceTintColor: Colors.white,
                      elevation: 10,
                      child: Container(
                        width: double
                            .infinity, // Use double.infinity for the card width
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Login Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildLoginInfoRow('Email:', email),
                              _buildLoginInfoRow('Password:', password),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  editLoginInfo(); // Call method to edit login information
                                },
                                child: Text('Edit Login Information'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Profile Picture',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  // Pick image using ImagePickerWeb
                                  Uint8List? imageBytes =
                                      await ImagePickerWeb.getImageAsBytes();

                                  if (imageBytes != null) {
                                    setState(() {
                                      _imageBytes = imageBytes;
                                    });
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: _imageBytes != null
                                      ? MemoryImage(_imageBytes!)
                                      : null,
                                  child: _imageBytes == null
                                      ? Icon(Icons.camera_alt, size: 50)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(
      String title, String value, ValueChanged<String> onChanged) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: TextField(
              decoration: InputDecoration(
                labelText: title,
                border: OutlineInputBorder(),
              ),
              onChanged: onChanged,
              controller: TextEditingController(text: value),
              textDirection: ui.TextDirection.ltr),
        ),
      ],
    );
  }

  Widget _buildLoginInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$title $value',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
