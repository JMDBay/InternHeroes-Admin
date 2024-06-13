import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('knowledge_resource')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Display a loading indicator while data is being fetched
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // Extract documents from the snapshot
        final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

        // Count the number of pending posts
        int pendingCount =
            documents.where((doc) => doc['status'] == 'pending').length;

        return Text(
          'Number of Pending Posts: ${pendingCount == 0 ? 0 : pendingCount}',
          style: TextStyle(fontSize: 16),
        );
      },
    );
  }
}
