// Redesigned Challenge Screen UI - Styled like reference
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProPairXChallengeScreen extends StatefulWidget {
  const ProPairXChallengeScreen({super.key});

  @override
  State<ProPairXChallengeScreen> createState() =>
      _ProPairXChallengeScreenState();
}

class _ProPairXChallengeScreenState extends State<ProPairXChallengeScreen> {
  DocumentSnapshot? challengeDoc;
  final TextEditingController controller = TextEditingController();
  bool isLoading = true;
  bool isSolved = false;
  String feedback = '';
  List<dynamic> leaderboard = [];

  @override
  void initState() {
    super.initState();
    loadChallenge();
  }

  Future<void> loadChallenge() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('propairx_challenge')
          .doc('current')
          .get();

      if (!mounted) return;
      setState(() {
        challengeDoc = doc;
        leaderboard = (doc['leaderboard'] ?? []) as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        feedback = '⚠️ Error loading challenge';
        isLoading = false;
      });
    }
  }

  void submitSolution() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || challengeDoc == null || leaderboard.length >= 3) return;

    final String userCode = controller.text.trim();
    final String expectedOutput = challengeDoc!['expectedOutput'];

    final String mockedOutput = userCode.contains('sorted')
        ? "[1, 2, 3]"
        : "wrong";

    if (mockedOutput.trim() == expectedOutput.trim()) {
      if (leaderboard.any(
        (entry) => (entry is Map && entry['uid'] == user.uid),
      )) {
        if (!mounted) return;
        setState(() => feedback = '✅ Already completed!');
        return;
      }

      final nickname = 'User${user.uid.substring(0, 4)}';
      int xp = leaderboard.isEmpty
          ? 30
          : leaderboard.length == 1
          ? 20
          : 10;
      leaderboard.add({'uid': user.uid, 'nickname': nickname, 'xp': xp});

      try {
        await FirebaseFirestore.instance
            .collection('propairx_challenge')
            .doc('current')
            .update({'leaderboard': leaderboard});
      } catch (e) {
        if (!mounted) return;
        setState(() => feedback = '⚠️ Failed to update leaderboard.');
        return;
      }

      if (!mounted) return;
      setState(() {
        isSolved = true;
        feedback = '🎉 Correct! You earned $xp XP';
      });
    } else {
      if (!mounted) return;
      setState(() => feedback = '❌ Incorrect output. Try again!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0E12),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE9455A)),
        ),
      );
    }

    final data = challengeDoc?.data() as Map<String, dynamic>?;
    if (!(data?['isActive'] == true)) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0E12),
        body: Center(
          child: Text(
            'No active challenge right now.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const Text(
                    'ProPairX Weekly Challenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '03:19',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                data?['title'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF5555),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data?['description'] ?? '',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                "Buggy Code:",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  data?['code'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Your Fix:", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1D),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    hintText: 'Your fix here...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: leaderboard.length < 3 ? submitSolution : null,
                icon: const Icon(Icons.check_box, color: Colors.black),
                label: const Text(
                  "Submit Fix",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE9455A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              if (feedback.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    feedback,
                    style: const TextStyle(color: Colors.amberAccent),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                "🏆 Leaderboard",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...List.from(leaderboard.take(3)).asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final dynamic entryValue = entry.value;
                if (entryValue is! Map<String, dynamic>)
                  return const SizedBox();
                final data = entryValue;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE9455A),
                    child: Text(
                      '$rank',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(
                    data['nickname'] ?? 'Anonymous',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    "+${data['xp']} XP",
                    style: const TextStyle(
                      color: Color(0xFF2ECC71),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
