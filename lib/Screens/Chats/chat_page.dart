import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth/service/database_service.dart';
import 'otherprofilescreen.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final String recipientId;
  final String? recipientName;

  const ChatPage({
    Key? key,
    required this.recipientId,
    this.recipientName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String currentUserId;
  late Stream<QuerySnapshot> chats = Stream.empty();
  TextEditingController messageController = TextEditingController();
  final DatabaseService databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
        getChats();
      });
    } else {
      // Handle the case where the user is not signed in
      // Redirect to sign-in or handle appropriately
    }
  }

  void getChats() {
    setState(() {
      String chatId = getChatId(currentUserId, widget.recipientId);
      chats = databaseService.getChats(currentUserId, widget.recipientId);
    });
  }

  void sendMessage() {
    if (messageController.text.trim().isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "senderId": currentUserId,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      String chatId = getChatId(currentUserId, widget.recipientId);

      databaseService.sendMessage(chatId, chatMessageMap, widget.recipientId);

      setState(() {
        messageController.clear();
      });
    }
  }

  String getChatId(String userId1, String userId2) {
    List<String> sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to OtherProfileScreen when profile picture clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherProfileScreen(
                      uid: widget.recipientId,
                    ),
                  ),
                );
              },
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.recipientId)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(); // Return an empty SizedBox while loading
                  } else if (userSnapshot.hasError) {
                    return SizedBox(); // Return an empty SizedBox if there's an error
                  } else {
                    var userData = userSnapshot.data?.data();
                    if (userData == null || userData.isEmpty) {
                      // Check in admin collection if not found in users
                      return StreamBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('admin')
                            .doc(widget.recipientId)
                            .snapshots(),
                        builder: (context, adminSnapshot) {
                          if (adminSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(); // Return an empty SizedBox while loading
                          } else if (adminSnapshot.hasError) {
                            return SizedBox(); // Return an empty SizedBox if there's an error
                          } else {
                            var adminData = adminSnapshot.data?.data();
                            if (adminData == null || adminData.isEmpty) {
                              return SizedBox(); // Return an empty SizedBox if adminData is null or empty
                            }
                            String? adminProfileImageUrl =
                                adminData['profileImageUrl'] as String?;
                            return adminProfileImageUrl != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(adminProfileImageUrl),
                                  )
                                : SizedBox(); // Return an empty SizedBox if adminProfileImageUrl is null
                          }
                        },
                      );
                    }
                    String? userProfileImageUrl =
                        userData['profileImageUrl'] as String?;
                    return userProfileImageUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(userProfileImageUrl),
                          )
                        : SizedBox(); // Return an empty SizedBox if profileImageUrl is null
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            Text(widget.recipientName ?? 'Chat with User'),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: chatMessages(),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            constraints: BoxConstraints(maxHeight: 150),
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: SizedBox(
              width: 1000, // Adjust the width as needed
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: TextFormField(
                            controller: messageController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 8.0),
                              hintText: 'Enter your message...',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: sendMessage,
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessages() {
    DateTime? lastDate;

    return StreamBuilder<QuerySnapshot>(
      stream: chats,
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatSnapshot.hasError) {
          return Center(
            child: Text('Error: ${chatSnapshot.error}'),
          );
        }
        final chatDocs = chatSnapshot.data?.docs ?? [];
        if (chatDocs.isEmpty) {
          return Center(
            child: Text('Say hello for the first time to this user!'),
          );
        }

        String chatId = getChatId(currentUserId, widget.recipientId);
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .doc(chatId)
              .collection("messages")
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (context, messageSnapshot) {
            if (messageSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (messageSnapshot.hasError) {
              return Center(
                child: Text('Error: ${messageSnapshot.error}'),
              );
            }
            final messageDocs = messageSnapshot.data?.docs ?? [];
            return ListView.builder(
              reverse: true,
              itemCount: messageDocs.length,
              itemBuilder: (context, index) {
                var message = messageDocs[index];
                bool isCurrentUser = message['senderId'] == currentUserId;

                DateTime messageTime =
                    DateTime.fromMillisecondsSinceEpoch(message['time'] ?? 0);

                bool isNewDate =
                    lastDate == null || lastDate!.day != messageTime.day;

                if (isNewDate) {
                  lastDate = messageTime;
                }

                bool displayDate =
                    isNewDate || (index == messageDocs.length - 1);

                return Column(
                  children: [
                    if (displayDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          DateFormat('MMMM dd, yyyy HH:mm').format(messageTime),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        constraints: BoxConstraints(maxWidth: 700),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? Colors.yellow[800]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Linkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  throw 'Could not launch $link';
                                }
                              },
                              text: message['message'] ?? '',
                              style: TextStyle(
                                color:
                                    isCurrentUser ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(messageTime),
                              style: TextStyle(
                                color:
                                    isCurrentUser ? Colors.white : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
