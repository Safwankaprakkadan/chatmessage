import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lilactest/api_service.dart';
import 'dart:convert';
import 'package:lilactest/chat_screen.dart';
import 'package:lilactest/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListScreen extends StatefulWidget {
  final String token;

  ChatListScreen({required this.token});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    fetchChatList();
    _loadToken();
  }

  void _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = widget.token ?? prefs.getString('auth_token');
    });
  }

  Future<void> fetchChatList() async {
    try {
      final chatList = await ApiService.getChatList(widget.token);
      setState(() {
        users = chatList.cast<Map<String, dynamic>>();
        filteredUsers = users;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching chat list: $error");
      setState(() => isLoading = false);

      if (error.toString().contains("Unauthenticated")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PhoneLoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load chat list. Please try again later."),
          ),
        );
      }
    }
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredUsers =
          users
              .where(
                (user) =>
                    user["name"].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        userName: users[index]["name"],
                                        userImage: NetworkImage(
                                          users[index]["profile_photo_url"],
                                        ),
                                        senderId: users[index]["auth_user_id"],
                                        receiverId: users[index]["id"],
                                        token: widget.token,
                                      ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      users[index]["profile_photo_url"] != null
                                          ? NetworkImage(
                                            users[index]["profile_photo_url"],
                                          )
                                          : null,
                                  child:
                                      users[index]["profile_photo_url"] == null
                                          ? Icon(Icons.person, size: 30)
                                          : null,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  users[index]["name"],
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ).paddingSymmetric(horizontal: 8),
                          );
                        },
                      ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                suffixIcon: Icon(Icons.search, size: 30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: filterSearchResults,
            ),
            SizedBox(height: 16),
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  filteredUsers[index]["profile_photo_url"] !=
                                          null
                                      ? NetworkImage(
                                        filteredUsers[index]["profile_photo_url"],
                                      )
                                      : null,
                              child:
                                  filteredUsers[index]["profile_photo_url"] ==
                                          null
                                      ? Icon(Icons.person)
                                      : null,
                            ),
                            title: Text(
                              filteredUsers[index]["name"],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _formatChatTime(
                                    filteredUsers[index]["message_received_from_partner_at"],
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        userName: filteredUsers[index]["name"],
                                        userImage: NetworkImage(
                                          filteredUsers[index]["profile_photo_url"],
                                        ),
                                        senderId: filteredUsers[index]["auth_user_id"],
                                        receiverId: filteredUsers[index]["id"],
                                        token: widget.token,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

extension PaddingExtensions on Widget {
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }
}

String _formatChatTime(String timestamp) {
  final dateTime = DateTime.parse(timestamp);
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    final timeFormat = DateFormat('h:mm a');
    return timeFormat.format(dateTime);
  } else if (difference.inDays == 1) {
    return "Yesterday";
  } else {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(dateTime);
  }
}
