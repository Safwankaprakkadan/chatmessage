import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final ImageProvider? userImage;
  final int senderId;
  final String receiverId;
  final String token;

  ChatScreen({
    required this.userName,
    this.userImage,
    required this.senderId,
    required this.receiverId,
    required this.token,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final messages = await ApiService.getChatBetweenUsers(
        widget.senderId,
        widget.receiverId,
        widget.token,
      );

      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "Failed to load messages. Please try again.";
        _isLoading = false;
      });
      print("Error fetching messages: $error");
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final newMessage = {
        "message": _messageController.text,
        "sent_at": DateTime.now().toIso8601String(),
        "sender_id": widget.senderId,
        "type": "text",
      };

      setState(() {
        _messages.add(newMessage);
      });
      _messageController.clear();
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: widget.userImage),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Online', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 2),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSender = message["sender_id"] == widget.senderId;

                          return Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isSender ? Colors.pink[300] : Colors.blue[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (message["type"] == "text")
                                      Text(
                                        message["message"],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    if (message["media_url"] != null)
                                      Image.network(
                                        message["media_url"],
                                        fit: BoxFit.cover,
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  _formatTimestamp(message["sent_at"]),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: Colors.pink[400],
                          ),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}