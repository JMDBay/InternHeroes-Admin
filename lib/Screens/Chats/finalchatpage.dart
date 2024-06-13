import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Chats/chat_page.dart';
import 'package:flutter_auth/Screens/Chats/chatlist.dart'; // Assuming you have a UserListPage widget
import 'package:flutter_auth/Screens/main/components/side_menu.dart'; // Import your SideMenu widget

class CombinedPage extends StatefulWidget {
  @override
  _CombinedPageState createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage> {
  String? _selectedRecipientId;
  String? _selectedRecipientName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            child: SideMenu(),
          ),
          VerticalDivider(),
          Expanded(
            flex: 1,
            child: UserListPage(
              onUserSelected: (recipientId, recipientName) {
                setState(() {
                  _selectedRecipientId = recipientId;
                  _selectedRecipientName = recipientName;
                });
              },
            ),
          ),
          VerticalDivider(),
          Expanded(
            flex: 3,
            child:
                _selectedRecipientId != null && _selectedRecipientName != null
                    ? ChatPage(
                        recipientId: _selectedRecipientId!,
                        recipientName: _selectedRecipientName!,
                        key: UniqueKey(),
                      )
                    : Center(
                        child: Text('No users are selected'),
                      ),
          ),
        ],
      ),
    );
  }
}
