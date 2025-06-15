import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/gpt_service.dart';
// import '../../services/stt_service.dart'; // ❌ STT temporarily disabled
import '../../services/tts_service.dart';
import 'interview_feedback_screen.dart';
import '../../widgets/ai_avatar.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  bool _isAiSpeaking = false;
  bool _hasStarted = false;
  String? domain;

  @override
  void initState() {
    super.initState();
    _getUserDomain();
  }

  Future<void> _getUserDomain() async {
    domain = "Software Engineer"; // TODO: Replace with Firestore call
  }

  Future<void> _startInterview() async {
    setState(() => _hasStarted = true);
    await _sendAIMessage("start");
  }

  Future<void> _sendAIMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": userMessage});
      _isSending = true;
    });

    final aiResponse = await GptService.fetchNextInterviewQuestion(
      domain: domain ?? "General",
      conversation: _messages
          .map(
            (msg) => {
              "role": msg['sender']?.toString() ?? '',
              "content": msg['text']?.toString() ?? '',
            },
          )
          .toList()
          .cast<Map<String, String>>(),
    );

    if (!mounted) return;
    setState(() => _isAiSpeaking = true);
    await TtsService.speak(aiResponse);
    if (!mounted) return;
    setState(() => _isAiSpeaking = false);

    setState(() {
      _messages.add({"sender": "ai", "text": aiResponse});
      _isSending = false;
    });
  }

  /*
  // 🔇 STT temporarily disabled
  Future<void> _listenAndSend() async {
    try {
      final recognizedText = await sttService.listenOnce();
      if (recognizedText.trim().isNotEmpty) {
        await _sendAIMessage(recognizedText);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Voice input not available: $e")));
    }
  }
  */

  Future<void> _endInterview() async {
    final formatted = _messages
        .map(
          (msg) => {
            "role": msg['sender']?.toString() ?? '',
            "content": msg['text']?.toString() ?? '',
          },
        )
        .toList()
        .cast<Map<String, String>>();

    final feedback = await GptService.fetchInterviewFeedback(
      domain: domain ?? "General",
      conversation: formatted,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InterviewFeedbackScreen(feedback: feedback),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF00E6D0) : const Color(0xFF1A1A1D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message['text'],
          style: GoogleFonts.inter(
            color: isUser ? Colors.black : Colors.white,
            fontSize: 14,
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
        title: Text(
          "AI Mock Interview",
          style: GoogleFonts.sora(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: _hasStarted
            ? [
                IconButton(
                  tooltip: "End Interview",
                  icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
                  onPressed: _isSending ? null : _endInterview,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: !_hasStarted
            ? Center(
                child: ElevatedButton(
                  onPressed: _startInterview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E6D0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Start Interview",
                    style: GoogleFonts.sora(fontSize: 16),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AiAvatar(isSpeaking: _isAiSpeaking),
                  ),
                  const Divider(height: 1, color: Colors.white24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.mic_off, color: Colors.grey),
                          onPressed: null, // Disabled mic button
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Type your answer...",
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: _sendAIMessage,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            _isSending ? Icons.hourglass_bottom : Icons.send,
                            color: const Color(0xFF00E6D0),
                          ),
                          onPressed: _isSending
                              ? null
                              : () => _sendAIMessage(_controller.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
