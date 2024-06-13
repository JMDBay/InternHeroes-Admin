import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserListPage extends StatefulWidget {
  final Function(String recipientId, String recipientName) onUserSelected;

  const UserListPage({Key? key, required this.onUserSelected})
      : super(key: key);

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late TextEditingController _searchController;
  late Stream<QuerySnapshot> _usersStream;
  String? _selectedUserId; // Track the selected user ID
  String _searchQuery = ''; // Store the current search query

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery =
          _searchController.text.toLowerCase(); // Update the search query
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Chats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Interns'),
              Tab(text: 'Admins'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildInternList(),
                  _buildAdminListWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternList() {
    return StreamBuilder(
      stream: _usersStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No interns available'));
        } else {
          List<DocumentSnapshot> filteredUsers =
              _filterUsers(snapshot.data!.docs);
          return _buildUserList(filteredUsers);
        }
      },
    );
  }

  Widget _buildAdminListWidget() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('admin').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No admins available'));
        } else {
          List<DocumentSnapshot> filteredAdmins =
              _filterAdmins(snapshot.data!.docs);
          return _buildAdminList(filteredAdmins);
        }
      },
    );
  }

  List<DocumentSnapshot> _filterUsers(List<DocumentSnapshot> users) {
    return users.where((user) {
      Map<String, dynamic>? userData =
          user.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
      if (userData != null) {
        // Check if all required fields exist in the document data
        bool hasAllRequiredFields = userData.containsKey('birthday') &&
            userData.containsKey('careerPath') &&
            userData.containsKey('email') &&
            userData.containsKey('name') &&
            userData.containsKey('ojtCoordinatorEmail') &&
            userData.containsKey('phoneNumber') &&
            userData.containsKey('profileImageUrl') &&
            userData.containsKey('university') &&
            userData.containsKey('yearAndCourse');

        if (hasAllRequiredFields) {
          // Check if the user's name contains the search query
          String name = userData['name']?.toLowerCase() ?? '';
          return name.contains(_searchQuery.toLowerCase());
        } else {
          // If any required fields are missing, exclude the user
          return false;
        }
      } else {
        // If document data is null, exclude the user
        return false;
      }
    }).toList();
  }

  List<DocumentSnapshot> _filterAdmins(List<DocumentSnapshot> admins) {
    return admins.where((admin) {
      String firstName = admin['firstName']?.toLowerCase() ?? '';
      String lastName = admin['lastName']?.toLowerCase() ?? '';
      String fullName = '$firstName $lastName';
      return fullName.contains(_searchQuery);
    }).toList();
  }

  Widget _buildUserList(List<DocumentSnapshot> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        var user = users[index];

        // Check if all required fields are present
        bool hasAllRequiredFields = user['birthday'] != null &&
            user['careerPath'] != null &&
            user['email'] != null &&
            user['name'] != null &&
            user['ojtCoordinatorEmail'] != null &&
            user['phoneNumber'] != null &&
            user['profileImageUrl'] != null &&
            user['university'] != null &&
            user['yearAndCourse'] != null;

        // Only build the ListTile if all required fields are present
        if (hasAllRequiredFields) {
          String? profileImageUrl = user['profileImageUrl'];
          String name = user['name'] ?? 'Name not available';
          bool isSelected = user.id == _selectedUserId;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              tileColor: isSelected ? Colors.blue.withOpacity(0.2) : null,
              leading: CircleAvatar(
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : AssetImage('assets/superhero.jpg')
                        as ImageProvider<Object>,
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedUserId = user.id;
                });
                widget.onUserSelected(user.id, name);
              },
            ),
          );
        } else {
          // If any required fields are missing, filter out the user
          return SizedBox
              .shrink(); // This will create an empty, non-visible widget
        }
      },
    );
  }

  Widget _buildAdminList(List<DocumentSnapshot> admins) {
    return ListView.builder(
      itemCount: admins.length,
      itemBuilder: (context, index) {
        var admin = admins[index];
        String firstName = admin['firstName'] ?? 'First name not available';
        String lastName = admin['lastName'] ?? 'Last name not available';
        String fullName = '$firstName $lastName';
        bool isSelected =
            admin.id == _selectedUserId; // Check if this admin is selected

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ListTile(
            tileColor: isSelected ? Colors.blue.withOpacity(0.2) : null,
            title: Text(
              fullName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                _selectedUserId = admin.id; // Update the selected user ID
              });
              widget.onUserSelected(admin.id, fullName);
            },
          ),
        );
      },
    );
  }
}
