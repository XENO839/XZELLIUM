import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debug_challenge.dart';

Future<List<DebugChallenge>> fetchDailyChallenges() async {
  // ✅ Fixed demo date to always load the same challenges
  const String datePath = "2025-06-01";

  final List<DebugChallenge> challenges = [];

  for (int i = 1; i <= 4; i++) {
    final doc = await FirebaseFirestore.instance
        .collection('debug_challenges')
        .doc(datePath)
        .collection('challenge$i')
        .doc('data')
        .get();

    if (doc.exists) {
      challenges.add(DebugChallenge.fromMap(doc.data()!));
    }
  }

  return challenges;
}
