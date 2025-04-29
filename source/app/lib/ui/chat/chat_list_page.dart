import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ChatScreen extends StatefulWidget {
  final int userId; // 131 hoặc 139

  ChatScreen({required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StompClient _stompClient;
  List<Map<String, dynamic>> _messages = [];
  TextEditingController _messageController = TextEditingController();
  late int _receiverId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _receiverId = widget.userId == 131 ? 139 : 131;
    _connectWebSocket();
    _loadMessages();
  }

  void _connectWebSocket() {
    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://172.20.10.3:8080/ws',
        onConnect: _onConnect,
        onWebSocketError: (error) => print('WebSocket Error: $error'),
      ),
    );

    _stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    print('Connected to WebSocket');
    _stompClient.subscribe(
      destination: '/topic/chat',
      callback: (frame) {
        if (frame.body != null) {
          final received = jsonDecode(frame.body!);
          setState(() {
            _messages.add(received);
          });
          _scrollToBottom();
        }
      },
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now().toIso8601String();
    Map<String, dynamic> message = {
      'sender_id': widget.userId,
      'receiver_id': _receiverId,
      'content': text,
      'sentAt': now,
    };

    _stompClient.send(
      destination: '/app/sendMessage',
      body: jsonEncode(message),
    );

    _messageController.clear();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://172.20.10.3:8080/api/chat/messages/${widget.userId}/$_receiverId',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> messages = jsonDecode(response.body);
        setState(() {
          _messages = messages.map((e) => e as Map<String, dynamic>).toList();
        });
        _scrollToBottom();
      } else {
        print('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dt = DateTime.parse(isoTime);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == widget.userId;
    final content = msg['content'] ?? '';
    final time = _formatTime(msg['sentAt']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[400] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat với $_receiverId')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => _buildMessageBubble(_messages[i]),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
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
