import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class CloudStorageInfo {
  final String? svgSrc, title;
  int? numOfUsers; // Updated to int
  final int? percentage;
  final Color? color;
  String? totalStorage;

  CloudStorageInfo({
    this.svgSrc,
    this.title,
    this.totalStorage,
    this.numOfUsers, // Updated
    this.percentage,
    this.color,
  });
}

List<CloudStorageInfo> demoMyFiles = [
  CloudStorageInfo(
    title: "UI/UX",
    svgSrc: "assets/icons/Documents.svg",
    totalStorage: "8",
    color: primaryColor,
    percentage: 12,
  ),
  CloudStorageInfo(
    title: "Flutter",
    svgSrc: "assets/icons/google_drive.svg",
    totalStorage: "2",
    color: Color(0xFFFFA113),
    percentage: 35,
  ),
  CloudStorageInfo(
    title: "Vercel",
    svgSrc: "assets/icons/one_drive.svg",
    totalStorage: "5", // Replace with actual count
    color: Color(0xFFA4CDFF),
    percentage: 10,
  ),
];

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user data from Firestore
  Future<Map<String, int>> fetchUsersCareerPaths() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      Map<String, int> careerPathsCount = {};

      // Iterate through each user document using a for loop
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Get the list of career paths for the current user
        List<dynamic> userCareerPaths = doc['careerPath'];

        // Check if the career path contains "Vercel"
        if (userCareerPaths.contains("Vercel")) {
          careerPathsCount["Vercel"] = (careerPathsCount["Vercel"] ?? 0) + 1;
        }
      }
      return careerPathsCount;
    } catch (e) {
      print('Error fetching users data: $e');
      return {};
    }
  }
}

Future<void> updateDemoMyFilesList() async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  FirebaseService firebaseService = FirebaseService();
  Map<String, int> careerPathsCount =
      await firebaseService.fetchUsersCareerPaths();

  // Update the numOfUsers field in demoMyFiles with the count
  for (var fileInfo in demoMyFiles) {
    fileInfo.numOfUsers = careerPathsCount[fileInfo.title] ?? 0;

    // Update totalStorage to show the number of Vercel users
    if (fileInfo.title == "Vercel") {
      fileInfo.totalStorage = "${fileInfo.numOfUsers} users";
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await updateDemoMyFilesList();

  // Print the updated demoMyFiles list with total number of users under each category
  print(demoMyFiles);
}

class DemoContainer extends StatelessWidget {
  final Widget child;

  DemoContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white, // Change color to white
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }
}
