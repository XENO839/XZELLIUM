// 🎯 XChange Screen Revamped for Xzellium Neon UI
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'xchange_chat_screen.dart';

class XChangeScreen extends StatefulWidget {
  const XChangeScreen({super.key});

  @override
  State<XChangeScreen> createState() => _XChangeScreenState();
}

class _XChangeScreenState extends State<XChangeScreen> {
  final teachController = TextEditingController();
  final learnController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> teachSkills = [];
  List<String> learnSkills = [];
  Timestamp? lastUpdated;
  bool isLoading = false;
  String? matchedUserId;
  String? chatId;
  Timer? countdownTimer;
  Duration? timeLeft;

  @override
  void initState() {
    super.initState();
    _loadBarterProfile();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBarterProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => isLoading = true);

    final doc = await FirebaseFirestore.instance
        .collection('xchange_profiles')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      teachSkills = List<String>.from(data['teach'] ?? []);
      learnSkills = List<String>.from(data['learn'] ?? []);
      lastUpdated = data['timestamp'];
    }

    await _searchForMatch();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _saveBarterProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('xchange_profiles')
        .doc(user.uid)
        .set({
          'uid': user.uid,
          'teach': teachSkills,
          'learn': learnSkills,
          'timestamp': FieldValue.serverTimestamp(),
        });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🔒 Barter profile saved!')));

    await _searchForMatch();
  }

  Future<void> _searchForMatch() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || teachSkills.isEmpty || learnSkills.isEmpty) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('xchange_profiles')
        .get();

    for (final doc in snapshot.docs) {
      if (doc.id == user.uid) continue;

      final otherTeach = List<String>.from(doc['teach'] ?? []);
      final otherLearn = List<String>.from(doc['learn'] ?? []);

      final isMatch =
          teachSkills.any((s) => otherLearn.contains(s)) &&
          learnSkills.any((s) => otherTeach.contains(s));

      if (isMatch) {
        final sortedIds = [user.uid, doc.id]..sort();
        final generatedChatId = '${sortedIds[0]}_${sortedIds[1]}';

        final chatDoc = FirebaseFirestore.instance
            .collection('xchange_chats')
            .doc(generatedChatId);

        final chatSnapshot = await chatDoc.get();

        if (!chatSnapshot.exists) {
          await chatDoc.set({
            'user1': sortedIds[0],
            'user2': sortedIds[1],
            'matchedAt': FieldValue.serverTimestamp(),
          });
        } else {
          final matchedAt = chatSnapshot.data()?['matchedAt'] as Timestamp?;
          if (matchedAt != null) _startCountdown(matchedAt);
        }

        if (!mounted) return;
        setState(() {
          matchedUserId = doc.id;
          chatId = generatedChatId;
        });
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      matchedUserId = null;
      chatId = null;
    });
  }

  void _startCountdown(Timestamp matchedAt) {
    final expiry = matchedAt.toDate().add(const Duration(hours: 48));
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final left = expiry.difference(now);

      if (left.isNegative) {
        _autoUnmatch();
      } else {
        if (!mounted) return;
        setState(() => timeLeft = left);
      }
    });
  }

  Future<void> _autoUnmatch() async {
    countdownTimer?.cancel();
    final chatRef = FirebaseFirestore.instance
        .collection('xchange_chats')
        .doc(chatId);

    await chatRef.delete();

    if (!mounted) return;
    setState(() {
      chatId = null;
      matchedUserId = null;
      timeLeft = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏱ Match expired after 48 hours.')),
    );
  }

  void _addSkill(String type) {
    final skill =
        (type == 'teach' ? teachController.text : learnController.text).trim();
    if (skill.isEmpty) return;

    setState(() {
      final list = (type == 'teach' ? teachSkills : learnSkills);
      if (!list.contains(skill) && list.length < 3) {
        list.add(skill);
        (type == 'teach' ? teachController : learnController).clear();
        _scrollToBottom();
      } else {
        _showToast('Limit reached or already added!');
      }
    });
  }

  void _removeSkill(String type, int index) {
    setState(() {
      (type == 'teach' ? teachSkills : learnSkills).removeAt(index);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatCountdown(Duration? duration) {
    if (duration == null) return '';
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFFE9455A),
                  child: Icon(Icons.handshake, color: Colors.black, size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Skill Barter XChange",
                  style: TextStyle(
                    color: Color(0xFFE9455A),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Offer a skill, learn a skill — match anonymously!",
                  style: TextStyle(color: Colors.white38),
                ),
                const SizedBox(height: 24),
                if (matchedUserId != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF1A1A1D),
                      border: Border.all(color: Colors.tealAccent, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.tealAccent,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Matched with',
                                style: TextStyle(color: Colors.white60),
                              ),
                              Text(
                                matchedUserId!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Expires in: ${_formatCountdown(timeLeft)}',
                                style: const TextStyle(color: Colors.white38),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => XChangeChatScreen(
                            chatId: chatId!,
                            matchedUserId: matchedUserId!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble, color: Colors.black),
                    label: const Text('Start Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9455A),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                  ),
                ] else
                  const Text(
                    'No matches yet. Add your barter skills below 👇',
                    style: TextStyle(color: Colors.white38),
                  ),
                const SizedBox(height: 24),
                _buildSkillSection(
                  'Teach',
                  teachSkills,
                  teachController,
                  'teach',
                  Icons.school,
                ),
                const SizedBox(height: 20),
                _buildSkillSection(
                  'Learn',
                  learnSkills,
                  learnController,
                  'learn',
                  Icons.psychology,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillSection(
    String title,
    List<String> skills,
    TextEditingController controller,
    String type,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.amberAccent),
            const SizedBox(width: 6),
            Text(
              '$title:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(skills.length, (index) {
            return Chip(
              label: Text(
                skills[index],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF1A1A1D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.redAccent),
              ),
              deleteIcon: const Icon(Icons.close, color: Colors.white),
              onDeleted: () => _removeSkill(type, index),
            );
          }),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF1A1A1D),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add skill to $type',
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.redAccent),
                onPressed: () => _addSkill(type),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
