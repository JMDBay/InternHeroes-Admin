import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlutterUsersTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Users'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Filter users with "Flutter" in their careerPath
          List<UserListItem> userList = snapshot.data!.docs
              .map((doc) => UserListItem.fromDocumentSnapshot(doc))
              .where((user) => user.careerPath.contains('Flutter'))
              .toList();

          if (userList.isEmpty) {
            return Center(
              child: Text('No users found with "Flutter" in their careerPath.'),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowHeight: 50,
                    columnSpacing: 20,
                    columns: [
                      DataColumn(
                        label: Text('Name'.toUpperCase()),
                      ),
                      DataColumn(
                        label: Text('Career Path'.toUpperCase()),
                      ),
                      DataColumn(
                        label: Text('Required Hours'.toUpperCase()),
                      ),
                      DataColumn(
                        label: Text('University'.toUpperCase()),
                      ),
                      DataColumn(
                        label: Text('Phone Number'.toUpperCase()),
                      ),
                      DataColumn(
                        label: Text('OJT Coordinator Email'.toUpperCase()),
                      ),
                      DataColumn(
                        label: Text('Year and Course'.toUpperCase()),
                      ),
                      DataColumn(
                        // New column for Email
                        label: Text('Email'.toUpperCase()),
                      ),
                    ],
                    rows: List.generate(userList.length, (index) {
                      final user = userList[index];
                      final color =
                          index.isOdd ? Colors.grey[200] : Colors.white;

                      return DataRow(
                        color: MaterialStateColor.resolveWith(
                            (states) => color ?? Colors.transparent),
                        cells: [
                          DataCell(
                            Text(user.name),
                          ),
                          DataCell(
                            Text(user.careerPath.join(', ')),
                          ),
                          DataCell(
                            Text(user.requiredHours),
                          ),
                          DataCell(
                            Text(user.university),
                          ),
                          DataCell(
                            Text(user.phoneNumber),
                          ),
                          DataCell(
                            Text(user.ojtCoordinatorEmail),
                          ),
                          DataCell(
                            Text(user.yearAndCourse),
                          ),
                          DataCell(
                            // New DataCell for Email
                            Text(user.email),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserListItem {
  final String name;
  final List<String> careerPath;
  final String requiredHours;
  final String university;
  final String ojtCoordinatorEmail;
  final String yearAndCourse;
  final String phoneNumber;
  final String email; // Add email field

  UserListItem({
    required this.name,
    required this.careerPath,
    required this.requiredHours,
    required this.university,
    required this.ojtCoordinatorEmail,
    required this.yearAndCourse,
    required this.phoneNumber,
    required this.email, // Add email parameter
  });

  factory UserListItem.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final careerPathData = data['careerPath'];

    return UserListItem(
      name: data['name'] ?? 'None',
      careerPath: careerPathData != null && careerPathData is Iterable
          ? List<String>.from(careerPathData)
          : ['None'],
      requiredHours: data['requiredHours'] ?? 'None',
      university: data['university'] ?? 'None',
      ojtCoordinatorEmail: data['ojtCoordinatorEmail'] ?? 'None',
      yearAndCourse: data['yearAndCourse'] ?? 'None',
      phoneNumber: data['phoneNumber'] ?? 'None',
      email: data['email'] ?? 'None', // Add email parameter
    );
  }
}
