import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth/Screens/KnowledgeResource/pending.dart';

class PendingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Wrap the Card with GestureDetector
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AdminViewPage()), // Navigate to AdminViewPage
        );
      },
      child: Card(
        surfaceTintColor: Colors.white,
        margin: EdgeInsets.all(16),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pending Posts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('knowledge_resource')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> krSnapshot) {
                  if (krSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Centered loading indicator
                  }
                  if (krSnapshot.hasError) {
                    return Text('Error: ${krSnapshot.error}');
                  }

                  // Extract documents from the snapshot
                  final List<QueryDocumentSnapshot> krDocuments =
                      krSnapshot.data!.docs;

                  // Count the number of pending posts in knowledge_resource collection
                  int pendingCountKnowledgeResource = krDocuments
                      .where((doc) => doc['status'] == 'pending')
                      .length;

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot> coursesSnapshot) {
                      if (coursesSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child:
                                CircularProgressIndicator()); // Centered loading indicator
                      }
                      if (coursesSnapshot.hasError) {
                        return Text('Error: ${coursesSnapshot.error}');
                      }

                      // Extract documents from the snapshot
                      final List<QueryDocumentSnapshot> coursesDocuments =
                          coursesSnapshot.data!.docs;

                      // Count the number of pending posts in courses collection
                      int pendingCountCourses = coursesDocuments
                          .where((doc) => doc['status'] == 'pending')
                          .length;

                      // Calculate total pending count
                      int totalPendingCount =
                          pendingCountKnowledgeResource + pendingCountCourses;

                      // Calculate completion percentage for knowledge resource and courses
                      double krCompletionPercentage =
                          pendingCountKnowledgeResource / totalPendingCount;
                      double coursesCompletionPercentage =
                          pendingCountCourses / totalPendingCount;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 180,
                            width: 180,
                            child: CustomPaint(
                              painter: CirclePainter(
                                krPercentage: krCompletionPercentage,
                                coursesPercentage: coursesCompletionPercentage,
                                krColor: Colors.amber.shade800,
                                coursesColor: Colors.green,
                                totalPending: totalPendingCount,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              Text(
                                'Knowledge Resource: $pendingCountKnowledgeResource',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Courses and certificates: $pendingCountCourses',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double krPercentage;
  final double coursesPercentage;
  final Color krColor;
  final Color coursesColor;
  final int totalPending;

  CirclePainter({
    required this.krPercentage,
    required this.coursesPercentage,
    required this.krColor,
    required this.coursesColor,
    required this.totalPending,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 12; // Increased thickness
    final double halfStrokeWidth = strokeWidth / 2;

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    // Draw knowledge resource
    if (krPercentage > 0) {
      paint.color = krColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        pi * 2 * krPercentage,
        false,
        paint,
      );
    }

    // Draw courses
    if (coursesPercentage > 0) {
      paint.color = coursesColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + pi * 2 * krPercentage,
        pi * 2 * coursesPercentage,
        false,
        paint,
      );
    }

    // Draw text inside the circle
    TextSpan span = TextSpan(
      style: TextStyle(color: Colors.black, fontSize: 20),
      text: 'Pending\n$totalPending',
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.krPercentage != krPercentage ||
        oldDelegate.coursesPercentage != coursesPercentage ||
        oldDelegate.krColor != krColor ||
        oldDelegate.coursesColor != coursesColor ||
        oldDelegate.totalPending != totalPending;
  }
}
