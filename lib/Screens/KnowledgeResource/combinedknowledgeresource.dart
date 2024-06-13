import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/KnowledgeResource/knowledge_resource.dart';
import 'package:flutter_auth/Screens/KnowledgeResource/courses.dart'; // Import the CoursesCertificatesPage

class KnowledgeResourceAndCoursesPage extends StatefulWidget {
  @override
  _KnowledgeResourceAndCoursesState createState() =>
      _KnowledgeResourceAndCoursesState();
}

class _KnowledgeResourceAndCoursesState
    extends State<KnowledgeResourceAndCoursesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child:
                KnowledgeResourcePage(), // Include KnowledgeResourcePage here
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(16),
              child:
                  CoursesCertificatesPage(), // Display the CoursesCertificatesPage here
            ),
          ),
        ],
      ),
    );
  }
}
