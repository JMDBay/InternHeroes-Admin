import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth/Screens/main/components/side_menu.dart';

class AdminViewPage extends StatefulWidget {
  @override
  _AdminViewPageState createState() => _AdminViewPageState();
}

class _AdminViewPageState extends State<AdminViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Requests'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 200, // Adjust width as needed for the side menu
            child: SideMenu(), // Your SideMenu widget
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 200, // Width of the side menu
            right: 0,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Knowledge Resource'),
                      Tab(text: 'Courses'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPendingPosts('knowledge_resource'),
                        _buildPendingPosts('courses'),
                      ],
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

  Widget _buildPendingPosts(String collection) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No pending posts.'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Card(
            surfaceTintColor: Colors.white,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Tags')),
                DataColumn(label: Text('Action')),
              ],
              rows: snapshot.data!.docs.map<DataRow>((document) {
                String userName = document['userName'] ?? 'Unknown';
                String title = document['title'] ?? 'No Title';
                List<dynamic> tags = document['tags'] ?? [];

                return DataRow(
                  cells: [
                    DataCell(Text(userName)),
                    DataCell(Text(title)),
                    DataCell(Text(tags.join(', '))),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _approvePost(document.id, collection),
                        child: Text('Approve'),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _approvePost(String postId, String collection) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(postId)
          .update({
        'status': 'approved', // Change status to approved
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post approved successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving post: $error')),
      );
    }
  }
}
