import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'chat_model.dart';
import 'package:http/http.dart' as http;

class AdminChatDetailPage extends StatefulWidget {
  final int userId;
  final int sentId;
  final String userName;

  final StompClient stompClient;
  final Function(String) onMessageSent;

  AdminChatDetailPage({
    required this.userId,
    required this.userName,
    required this.sentId,
    required this.stompClient,
    required this.onMessageSent,
  });

  @override
  _AdminChatDetailPageState createState() => _AdminChatDetailPageState();
}

class _AdminChatDetailPageState extends State<AdminChatDetailPage> {
  late StompClient _stompClient;
  List<Map<String, dynamic>> _messages = [];
  TextEditingController _messageController = TextEditingController();
  late int _receiverId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _stompClient = widget.stompClient;
    _receiverId = widget.sentId;
    _connectWebSocket();
    _loadMessages();
  }

  void _connectWebSocket() {
    if (!_stompClient.isActive) {
      _stompClient.activate();
    }

    _stompClient.subscribe(
      destination: '/topic/chat',
      callback: (frame) {
        if (frame.body != null) {
          final received = jsonDecode(frame.body!);
          if (received['receiver_id'] == widget.userId ||
              received['sender_id'] == widget.userId) {
            _scrollToBottom();
          }
        }
      },
    );
  }

  void _onConnect(StompFrame frame) {
    print('Connected to WebSocket');
    _stompClient.subscribe(
      destination: '/topic/chat',
      callback: (frame) {
        if (frame.body != null) {
          final received = jsonDecode(frame.body!);

          if (received['receiver_id'] == widget.userId ||
              received['sender_id'] == widget.userId) {
            setState(() {
              _messages.add(received);
            });
            _scrollToBottom();
          }
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

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    _scrollToBottom();

    widget.onMessageSent(text);
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.70.182:8080/api/chat/messages/${widget.userId}/$_receiverId',
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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => {Navigator.pop(context)},
        ),
        title: Text(widget.userName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.camera_alt_outlined, color: Colors.blue),
                  onPressed: () {},
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 30, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.keyboard_voice_rounded, color: Colors.blue),
                  onPressed: () {},
                ),

                // Dùng Flexible để input chỉ chiếm vừa đủ
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 36,
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Aa',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),

                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  iconSize: 25,
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
