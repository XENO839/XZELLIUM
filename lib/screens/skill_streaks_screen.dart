import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/debug_challenge_service.dart';
import '../models/debug_challenge.dart';
import '../services/debug_attempt_service.dart';

class SkillStreaksScreen extends StatefulWidget {
  const SkillStreaksScreen({super.key});

  @override
  State<SkillStreaksScreen> createState() => _SkillStreaksScreenState();
}

class _SkillStreaksScreenState extends State<SkillStreaksScreen> {
  List<DebugChallenge> challenges = [];
  bool isLoading = true;
  int dailyStreak = 0;
  int xp = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        dailyStreak = data?['streak'] ?? 0;
        xp = data?['xp'] ?? 0;
      }
    }

    challenges = await fetchDailyChallenges();
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE9455A)),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🔥 Streak: $dailyStreak',
                        style: const TextStyle(
                          color: Color(0xFFE9455A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '💎 XP: $xp',
                        style: const TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: challenges.isEmpty
                      ? const Center(
                          child: Text(
                            "No challenges available today",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: challenges.length,
                          itemBuilder: (context, index) {
                            final challenge = challenges[index];
                            return DebugChallengeCard(challenge: challenge);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class DebugChallengeCard extends StatefulWidget {
  final DebugChallenge challenge;

  const DebugChallengeCard({super.key, required this.challenge});

  @override
  State<DebugChallengeCard> createState() => _DebugChallengeCardState();
}

class _DebugChallengeCardState extends State<DebugChallengeCard> {
  final TextEditingController controller = TextEditingController();
  int attemptsLeft = 4;
  bool isSolved = false;

  Future<void> checkSolution() async {
    final fixedCode = controller.text.trim();
    if (fixedCode.isEmpty) return;

    setState(() => attemptsLeft--);

    final isCorrect = fixedCode.contains(widget.challenge.expectedOutput);

    if (isCorrect) {
      setState(() => isSolved = true);

      await saveChallengeResult(
        challengeId: widget.challenge.id,
        attempts: 4 - attemptsLeft,
        fixed: true,
        xp: 1,
      );

      await updateDailyStreak();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Correct! Challenge solved."),
          backgroundColor: Color(0xFF2ECC71),
        ),
      );
    } else {
      if (!mounted) return;

      if (attemptsLeft > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Incorrect. $attemptsLeft attempts left."),
            backgroundColor: const Color(0xFFE9455A),
          ),
        );
      } else {
        await saveChallengeResult(
          challengeId: widget.challenge.id,
          attempts: 4,
          fixed: false,
          xp: 0,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚫 Challenge failed."),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.shade400, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Challenge ${widget.challenge.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.challenge.buggyCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF00FF88),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '💡 Hint: ${widget.challenge.hint}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          const Text(
            "Your Fix:",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: TextField(
              controller: controller,
              maxLines: null,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Type your fixed code...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: isSolved || attemptsLeft == 0 ? null : checkSolution,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  isSolved
                      ? 'Solved'
                      : attemptsLeft > 0
                      ? 'Run Fix'
                      : 'Failed',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSolved
                      ? const Color(0xFF2ECC71)
                      : attemptsLeft > 0
                      ? const Color(0xFFE9455A)
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              if (isSolved)
                const Text(
                  '+25 XP',
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
