import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth/Screens/KnowledgeResource/postdetailscerts.dart';

class CoursesCertificatesPage extends StatefulWidget {
  @override
  _CoursesCertificatesPageState createState() =>
      _CoursesCertificatesPageState();
}

class _CoursesCertificatesPageState extends State<CoursesCertificatesPage> {
  final List<String> allTags = [
    "UI/UX",
    "Vercel",
    "Webflow",
    "Flutter",
    "Programming",
    "Database Manager",
    "System Administrator",
    "Quality Assurance",
    "Service Assurance",
  ];
  late TextEditingController _searchController;
  late Query _coursesQuery;
  late Stream<QuerySnapshot> _coursesStream;
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _coursesQuery = FirebaseFirestore.instance.collection('courses');
    _coursesStream = _coursesQuery.snapshots();
    _selectedTags = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchCourses(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _coursesQuery = FirebaseFirestore.instance
            .collection('courses')
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThan: query + 'z');
      } else {
        _coursesQuery = FirebaseFirestore.instance.collection('courses');
      }
      _coursesStream = _coursesQuery.snapshots();
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Filter by Tags'),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  children: allTags.map((tag) {
                    bool isSelected = _selectedTags.contains(tag);
                    return TextButton(
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.remove(tag);
                          } else {
                            _selectedTags.add(tag);
                          }
                        });
                        // Update isSelected value immediately
                        isSelected = !isSelected;
                        _searchCourses(_searchController.text);
                      },
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          isSelected ? Colors.orange : Colors.grey[300]!,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCoursesList() {
    return Card(
      surfaceTintColor: Color.fromARGB(255, 55, 157, 208),
      margin: EdgeInsets.all(0), // Add margin to the card
      elevation: 5, // Add elevation for shadow effect
      child: Padding(
        padding:
            const EdgeInsets.all(8.0), // Add padding around the card content
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by title',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchCourses('');
                          },
                        ),
                      ),
                      onChanged: (value) {
                        _searchCourses(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _coursesStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No courses available'),
                    );
                  } else {
                    // Filter out courses with status 'pending'
                    final approvedCourses = snapshot.data!.docs
                        .where((course) => course['status'] == 'approved')
                        .toList();

                    if (approvedCourses.isEmpty) {
                      return Center(
                        child: Text('No approved courses available'),
                      );
                    }
                    return ListView.builder(
                      itemCount: approvedCourses.length,
                      itemBuilder: (context, index) {
                        var course = approvedCourses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildCourseCard(course),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(DocumentSnapshot course) {
    Timestamp timestamp = course['datePosted'];
    DateTime postDateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    Duration difference = now.difference(postDateTime);
    String postDate = _getPostDate(difference);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => PostDetailsDialog(post: course),
        );
      },
      child: Card(
        surfaceTintColor: Colors.white,
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding:
              const EdgeInsets.all(8.0), // Add padding around the card content
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (course['tags'] as List<dynamic>)
                          .map<Widget>((tag) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.yellow[800],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: Text(tag),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 50), // Adjust the top padding here
                      child: Text(
                        postDate,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              // Display course image if available
              if (course['imageUrls'] != null &&
                  (course['imageUrls'] as List).isNotEmpty)
                Container(
                  height: 100,
                  width: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: course['imageUrls'].length,
                    itemBuilder: (context, imageIndex) {
                      var imageUrl = course['imageUrls'][imageIndex];
                      if (imageUrl is String) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Text('Image not available');
                              },
                            ),
                          ),
                        );
                      } else {
                        return Text('Invalid image URL');
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPostDate(Duration difference) {
    if (difference.inDays > 365) {
      int years = (difference.inDays / 365).floor();
      return '$years' + 'y ago';
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return '$months' + 'm ago';
    } else if (difference.inDays >= 7) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks' + 'w ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}min ago';
    } else if (difference.inSeconds >= 1) {
      return '${difference.inSeconds}s ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCoursesList(),
    );
  }
}
