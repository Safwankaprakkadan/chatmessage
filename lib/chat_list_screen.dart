import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lilactest/chat_screen.dart';

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

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  Future<void> fetchChatList() async {
    const String baseUrl = "https://test.myfliqapp.com/api/v1";
    final String apiUrl = "$baseUrl/chat/chat-messages/queries/contact-users";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer ${widget.token}'
        },
      );

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            users = data.cast<Map<String, dynamic>>();
            filteredUsers = users;
            isLoading = false;
          });
        } else {
          throw Exception("Server returned non-JSON response.");
        }
      } else {
        throw Exception("Failed to load chat list. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching chat list: $error");
      setState(() => isLoading = false);
    }
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredUsers = users.where(
        (user) => user["name"].toLowerCase().contains(query.toLowerCase()),
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: isLoading
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
                                builder: (context) => ChatScreen(
                                  userName: users[index]["name"],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: users[index]["profile_image"] != null
                                    ? NetworkImage(users[index]["profile_image"])
                                    : null,
                                child: users[index]["profile_image"] == null
                                    ? Icon(Icons.person, size: 30)
                                    : null,
                              ),
                              SizedBox(height: 5),
                              Text(
                                users[index]["name"],
                                style: TextStyle(fontSize: 12),
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: filterSearchResults,
            ),
            SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: filteredUsers[index]["profile_image"] != null
                                ? NetworkImage(filteredUsers[index]["profile_image"])
                                : null,
                            child: filteredUsers[index]["profile_image"] == null
                                ? Icon(Icons.person)
                                : null,
                          ),
                          title: Text(filteredUsers[index]["name"]),
                          subtitle: Text(
                            filteredUsers[index]["last_message"] ?? "No messages",
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  userName: filteredUsers[index]["name"],
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
