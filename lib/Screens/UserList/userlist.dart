import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth/Screens/main/components/side_menu.dart';

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            child: SideMenu(),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white, // Set AppBar color to white
                  bottom: TabBar(
                    indicatorColor:
                        Colors.amber[800], // Change tab indicator color
                    tabs: [
                      Tab(
                        child: Text(
                          'Users',
                          style: TextStyle(
                              color:
                                  Colors.black), // Set tab text color to black
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Requests',
                          style: TextStyle(
                              color:
                                  Colors.black), // Set tab text color to black
                        ),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: UsersTab(),
                    ),
                    RequestsTab(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  int _pageNumber = 1; // Track the current page number
  int _pageSize = 10; // Number of rows per page
  late List<UserListItem>
      _userList; // List to hold user items for the current page

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Get the total number of users
        int totalUsers = snapshot.data!.docs.length;

        // Calculate the total number of pages based on page size
        int totalPages = (totalUsers / _pageSize).ceil();

        // Get the users for the current page
        _userList = snapshot.data!.docs
            .skip((_pageNumber - 1) * _pageSize)
            .take(_pageSize)
            .map((doc) {
          return UserListItem(
            name: doc.data().toString().contains('name')
                ? doc.get('name')
                : 'None',
            careerPath: doc.data().toString().contains('careerPath')
                ? List<String>.from(doc.get('careerPath'))
                : ['None'],
            requiredHours: doc.data().toString().contains('requiredHours')
                ? doc.get('requiredHours')
                : 'None',
            university: doc.data().toString().contains('university')
                ? doc.get('university')
                : 'None',
            ojtCoordinatorEmail:
                doc.data().toString().contains('ojtCoordinatorEmail')
                    ? doc.get('ojtCoordinatorEmail')
                    : 'None',
            yearAndCourse: doc.data().toString().contains('yearAndCourse')
                ? doc.get('yearAndCourse')
                : 'None',
            phoneNumber: doc.data().toString().contains('phoneNumber')
                ? doc.get('phoneNumber')
                : 'None',
            email: doc.data().toString().contains('email')
                ? doc.get('email')
                : 'None',
          );
        }).toList();

        return Center(
          child: Column(
            children: [
              Card(
                surfaceTintColor: Colors.white,
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DataTable(
                        headingRowHeight: 50,
                        dataRowHeight: 50,
                        columnSpacing: 10,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Name'.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Career Path'.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Required Hours'.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'University'.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Phone Number'.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'OJT Coordinator Email'.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Year and Course'.toUpperCase(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email'.toUpperCase(),
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                        rows: List.generate(_userList.length, (index) {
                          final user = _userList[index];
                          final color =
                              index.isOdd ? Colors.grey[200] : Colors.white;

                          return DataRow(
                            color: MaterialStateColor.resolveWith(
                              (states) => color ?? Colors.transparent,
                            ),
                            cells: [
                              DataCell(
                                Text(
                                  user.name,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.careerPath.join(', '),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.requiredHours,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.university,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.phoneNumber,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.ojtCoordinatorEmail,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.yearAndCourse,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.email,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _pageNumber > 1
                        ? () {
                            setState(() {
                              _pageNumber--;
                            });
                          }
                        : null,
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text('Page $_pageNumber of $totalPages'),
                  IconButton(
                    onPressed: _pageNumber < totalPages
                        ? () {
                            setState(() {
                              _pageNumber++;
                            });
                          }
                        : null,
                    icon: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class RequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('requests').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data?.docs;

        if (docs == null || docs.isEmpty) {
          return Center(
            child: Text('No data available'),
          );
        }

        return SingleChildScrollView(
          child: Card(
            surfaceTintColor: Colors.white,
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: DataTable(
                headingRowHeight: 40,
                dataRowHeight: 50,
                columnSpacing: 20,
                columns: [
                  DataColumn(
                    label: Text(
                      'Name'.toUpperCase(),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Email'.toUpperCase(),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions'.toUpperCase(),
                    ),
                  ),
                ],
                rows: docs.map((request) {
                  final color = docs.indexOf(request).isOdd
                      ? Colors.grey[200]
                      : Colors.white;

                  String buttonText = 'Accept';
                  Color buttonColor = Colors.yellow[800]!;
                  if (request['status'] == 'accepted') {
                    buttonText = 'Accepted';
                    buttonColor = Colors.grey;
                  }

                  return DataRow(
                    color: MaterialStateColor.resolveWith(
                        (states) => color ?? Colors.transparent),
                    cells: [
                      DataCell(
                        Text(
                          request['name'],
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          request['email'],
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          height: 30,
                          width: 80, // Adjust the width as needed
                          child: ElevatedButton(
                            onPressed: () {
                              if (request['status'] != 'accepted') {
                                _acceptRequest(
                                  context,
                                  request.id,
                                  request['name'],
                                  request['email'],
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Request already accepted'),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              buttonText,
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(buttonColor),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _acceptRequest(
      BuildContext context, String requestId, String name, String email) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference requestRef =
          FirebaseFirestore.instance.collection('requests').doc(requestId);
      transaction.update(requestRef, {'status': 'accepted'});

      // Update user status only if it's pending
      if (userIsActive(email)) {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;
          transaction.update(userDoc.reference, {'status': 'active'});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request accepted successfully')),
      );
    }).catchError((error) {
      print("Failed to accept request: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request')),
      );
    });
  }

  bool userIsActive(String email) {
    // Your logic to check if user is active
    return true; // Placeholder logic, replace with actual logic
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
}
