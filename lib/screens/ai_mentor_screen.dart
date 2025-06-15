// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xzellium/services/gpt_service.dart';
import 'package:xzellium/widgets/typing_indicator.dart';

class AiMentorScreen extends StatefulWidget {
  const AiMentorScreen({super.key});

  @override
  State<AiMentorScreen> createState() => _AiMentorScreenState();
}

class _AiMentorScreenState extends State<AiMentorScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    "How can I improve my DSA skills?",
    "What projects should I build for resumes?",
    "Suggest a roadmap for Flutter development",
    "How do I prepare for tech interviews?",
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mentorChat')
        .orderBy('timestamp')
        .get();

    final loadedMessages = snapshot.docs
        .map(
          (doc) => {
            'role': doc['role'] as String,
            'text': doc['text'] as String,
            'timestamp': doc['timestamp'],
          },
        )
        .toList();

    if (!mounted) return;

    setState(() {
      _messages.addAll(loadedMessages);
    });

    _scrollToBottom();
  }

  Future<void> _saveMessage(String role, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mentorChat')
        .add({
          'role': role,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  void _sendMessage([String? customText]) async {
    final user = FirebaseAuth.instance.currentUser;
    final input = customText ?? _controller.text.trim();
    if (user == null || input.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': input,
        'timestamp': DateTime.now(),
      });
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();
    await _saveMessage('user', input);

    final contextPrompt = [
      {
        "role": "system",
        "content":
            "You're a friendly and motivational AI mentor for tech students. Keep replies informative, brief, and supportive.",
      },
      ..._messages
          .map(
            (msg) => {
              'role': msg['role'] == 'user' ? 'user' : 'assistant',
              'content': msg['text'] ?? '',
            },
          )
          .cast<Map<String, String>>(),
    ];

    final reply = await GptService.fetchInsightFromGPTforChat(contextPrompt);

    setState(() {
      _messages.add({
        'role': 'mentor',
        'text': reply,
        'timestamp': DateTime.now(),
      });
      _isLoading = false;
    });

    await _saveMessage('mentor', reply);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _restartChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mentorChat');

    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    setState(() {
      _messages.clear();
      _controller.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat restarted.'),
        backgroundColor: Color(0xFF00E6D0),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF4C00FF) : const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isUser ? Colors.purple.withOpacity(0.3) : Colors.black26,
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildQuickPrompt(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C00FF), Color(0xFF00E6D0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "AI Mentor",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _restartChat,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_messages.isEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _quickPrompts.map(_buildQuickPrompt).toList(),
                ),
              ),
            ),
          if (_messages.isNotEmpty)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(
                    msg['text'] ?? '',
                    msg['role'] == 'user',
                  );
                },
              ),
            ),
          if (_isLoading) const TypingIndicator(),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1D),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ask your mentor...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF00E6D0),
                    child: Icon(Icons.send, color: Colors.black),
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
