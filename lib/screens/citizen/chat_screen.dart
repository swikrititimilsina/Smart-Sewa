// lib/screens/citizen/chat_screen.dart

import 'package:flutter/material.dart';
import '../../services/chatbot_api.dart';
import '../../models/user_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatbotApi _api = ChatbotApi();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  // Use the logged-in user's phone as the session ID
  // so conversation memory stays consistent for this user
  String get _sessionId =>
      UserSession.loggedInPhone.isNotEmpty
          ? UserSession.loggedInPhone
          : "guest_session";

  @override
  void initState() {
    super.initState();
    _messages.add({
      "sender": "bot",
      "text": "Namaste! I am Smart Sathi. Ask me in English or नेपालीमा!",
      "lang": "en"
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text, "lang": ""});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final result = await _api.sendMessage(text, _sessionId);
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": result["response"],
          "lang": result["language"]
        });
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "Connection error. Please try again. / जडान त्रुटि भयो।",
          "lang": "en"
        });
        _isTyping = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Sathi Chat"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset conversation",
            onPressed: () async {
              await _api.resetChat(_sessionId);
              setState(() => _messages.clear());
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Smart Sathi is typing...",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  );
                }
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                final isNepali = msg["lang"] == "ne";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: isNepali ? 15 : 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type in English or नेपालीमा...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}