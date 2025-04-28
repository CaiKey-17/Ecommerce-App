// screens/chat_detail_screen.dart
import 'package:app/models/message.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final int currentUserId;
  final int partnerId;
  final String partnerName;

  ChatDetailScreen({
    required this.currentUserId,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();

  void loadHistory() async {
    // Giả lập dữ liệu, thay bằng call API backend của bạn
    setState(() {
      messages = [
        Message(
          senderId: widget.partnerId,
          receiverId: widget.currentUserId,
          content: "Chào bạn!",
          timestamp: DateTime.now().subtract(Duration(minutes: 3)),
        ),
        Message(
          senderId: widget.currentUserId,
          receiverId: widget.partnerId,
          content: "Chào bạn nhé!",
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  void sendMessage(String text) {
    setState(() {
      messages.add(
        Message(
          senderId: widget.currentUserId,
          receiverId: widget.partnerId,
          content: text,
          timestamp: DateTime.now(),
        ),
      );
    });
    _controller.clear();
    // Gửi qua WebSocket ở đây
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
    // Khởi tạo websocket service nếu cần
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.partnerName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.senderId == widget.currentUserId;
                return Container(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Nhập tin nhắn..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
